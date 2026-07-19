# maac_workflow — 3 tính năng đang bổ sung

> File này để track tiến độ, phòng khi làm dở bị ngắt (hết token/context). Đọc lại
> mục **Trạng thái** trước, rồi xem **Quyết định thiết kế** để hiểu vì sao chọn API
> như vậy, rồi làm tiếp theo **Checklist**.

## Bối cảnh

README đã đổi ví dụ eKYC -> Signup (xong). User yêu cầu bổ sung thêm 3 tính năng
thật vào package (không chỉ doc):

1. Một primitive cho pattern "chỉ 1 tác vụ chạy tại 1 thời điểm, subscribe mới thì
   cancel cái cũ" (ban đầu gọi tạm là `StreamWorkflowStep` nhưng user yêu cầu đổi
   tên vì đây là pattern chung — giống việc app chỉ show 1 loading toàn cục tại 1
   thời điểm — không riêng gì Stream).
2. Timeout cho step (hiện tại chỉ có `RetryStepDecorator`, chưa có timeout).
3. Nested-workflow composite: cho phép dùng cả một `WorkflowRunner`/nhóm step như
   một `WorkflowStep` bên trong workflow cha (hiện `WorkflowRunner` không tự làm
   `WorkflowStep` được).

## Quyết định thiết kế

### 1. `SingleFlightWorkflowRunner<TContext>` (thay cho "StreamWorkflowStep")
- Không làm 1 subclass của `WorkflowStep` — vì bản chất nó quản lý **cả một lượt
  chạy workflow** (nhiều step), không phải logic của riêng 1 step.
- Wrap quanh 1 `WorkflowRunner<TContext>` có sẵn. Mỗi lần gọi `.run(context)`:
  cancel token đang active (nếu có) → tạo `CancellationToken` mới → chạy runner
  với token đó. Có thêm `.cancel()` để dùng trong `onPause`/`onDispose`.
- File: `lib/src/single_flight_workflow_runner.dart`.
- Ví dụ dùng thực tế (đã viết trong README phần "Single, Restartable Task"): step
  tự viết bằng `Completer` + `token.onCancel()` (không cần base class riêng, vì
  đó chỉ là cách viết 1 `WorkflowStep` bình thường "chạy tới khi bị cancel") —
  không cần thêm abstraction `StreamWorkflowStep` nữa, tránh thừa API.

### 2. `TimeoutStepDecorator<TContext>`
- File: `lib/src/decorators/timeout.dart`, cùng cấp với `retry.dart`.
- Composable với `RetryStepDecorator` (bọc lồng nhau được), vd:
  `RetryStepDecorator(step: TimeoutStepDecorator(step: X(), timeout: ...), maxAttempts: 3)`.
- Quan trọng: KHÔNG dùng thẳng token của workflow cha để báo hết-giờ, vì cancel
  token cha sẽ làm cả workflow rơi vào trạng thái `WorkflowCancelled` (sai ý
  nghĩa — timeout phải là 1 `StepFailure` bình thường, để còn retry/rollback
  được). Giải pháp: tạo `innerToken` riêng, link `token.onCancel(innerToken.cancel)`
  để cancel từ cha vẫn lan xuống được, nhưng khi timeout thì chỉ cancel
  `innerToken` (để step con dừng việc đang làm, vd hủy subscription) rồi trả về
  `StepFailure(TimeoutException(...))`.

### 3. `WorkflowStepGroup<TContext>` (nested-workflow composite)
- File: `lib/src/composites/workflow_step_group.dart`, cùng cấp
  `conditional.dart`/`parallel.dart`.
- Nhận `id` + `List<WorkflowStep<TContext>> steps` (+ optional `listener`), bên
  trong tự tạo 1 `WorkflowRunner` con và chạy nó trong `execute()`.
- `execute()`: map `WorkflowSuccess` -> `StepSuccess`, `WorkflowFailure` ->
  `StepFailure`, `WorkflowCancelled` -> trả `StepFailure(WorkflowCancelledException())`
  (thực tế không quan trọng giá trị trả về ở case này vì `WorkflowRunner` cha sẽ
  tự `token.throwIfCancelled()` ngay sau khi `execute()` trả về, trước khi đọc
  kết quả — xem `runner.dart` dòng ~62-63).
- `rollback()`: sub-workflow đã tự rollback nội bộ nếu CHÍNH nó fail rồi, nên
  `rollback()` ở đây chỉ chạy trong trường hợp group THÀNH CÔNG nhưng 1 step sau
  đó (ở workflow cha) fail. Xử lý bằng cách gọi `rollback()` từng step con theo
  thứ tự ngược (LIFO), dựa trên quy ước sẵn có trong codebase: `rollback()` của
  từng step phải tự no-op an toàn nếu step đó chưa thực sự chạy (xem
  `ConditionalStep.rollback` đã làm vậy — luôn gọi thẳng `step.rollback()` không
  cần check điều kiện).

## Checklist

- [x] Đọc source hiện tại (`step.dart`, `runner.dart`, `result.dart`,
      `cancellation_token.dart`, `retry.dart`, `conditional.dart`, `parallel.dart`)
- [x] Cập nhật README: đổi eKYC -> Signup + thêm mục "Single, Restartable Task"
      (bản đầu, dùng Completer thủ công)
- [x] Code `lib/src/decorators/timeout.dart` (`TimeoutStepDecorator`)
- [x] Code `lib/src/composites/workflow_step_group.dart` (`WorkflowStepGroup`)
- [x] Code `lib/src/single_flight_workflow_runner.dart` (`SingleFlightWorkflowRunner`)
- [x] Export 3 file mới trong `lib/maac_workflow.dart`
- [x] Viết test cho cả 3 trong `test/maac_workflow_test.dart` (17 test, tất cả pass)
- [x] Cập nhật README:
      - Thêm mục "⏱️ Failing Slow Steps with `TimeoutStepDecorator`"
      - Thêm mục "🧩 Composing Large Flows with `WorkflowStepGroup`"
      - Sửa lại mục "🔂 Single, Restartable Task" để dùng
        `SingleFlightWorkflowRunner` thay vì quản token thủ công trong
        ViewModel
      - Thêm dòng vào "🚀 Key Features" cho cả 3 tính năng mới
- [x] Chạy `flutter test` trong `packages/maac_workflow` — 17/17 pass
- [x] Chạy `flutter analyze` — không có warning/error mới (2 issue còn lại là
      pre-existing, không liên quan thay đổi này: `unnecessary_library_name` ở
      `lib/maac_workflow.dart:1` và `unused_local_variable` ở 1 test cũ dòng 239)

## Trạng thái

**HOÀN TẤT.** Cả 3 tính năng đã code + test + doc xong:
`TimeoutStepDecorator`, `WorkflowStepGroup`, `SingleFlightWorkflowRunner`.
File này có thể xoá khi user xác nhận không cần giữ lại làm log nữa.
