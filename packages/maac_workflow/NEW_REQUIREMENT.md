# ĐẶC TẢ YÊU CẦU PHÁT TRIỂN PACKAGE: WORKFLOW TASK ENGINE (DART)
*Tài liệu phân tích hệ thống yêu cầu, quy tắc vòng đời, và chiến lược điều phối bất đồng bộ nâng cao.*

---

## 1. MỤC TIÊU CỐT LÕI (CORE GOALS)

*   **Tính Khai Báo (Declarative Workflow):** Loại bỏ hoàn toàn việc viết các hàm `if-else`, `try-catch` lồng nhau, hoặc gọi hàm callback thủ công ở tầng code product. Cấu trúc luồng xử lý phức tạp phải được cấu hình tường minh qua file định nghĩa.
*   **Minh Bạch Hóa Luồng Xử Lý (Transparency):** Cung cấp cái nhìn trực quan về thứ tự thực thi (bước nào chạy trước, bước nào chạy sau, bước nào chạy song song) giúp hệ thống dễ dàng debug và bảo trì (Maintainability) khi quy trình thay đổi.
*   **Kiểm Soát Trạng Thái Nghiêm Ngặt (Strict State Control):** Đảm bảo an toàn dữ liệu và tài nguyên hệ thống trong các kịch bản bất đồng bộ phức tạp (hủy luồng, lỗi đột xuất, gọi trùng luồng).

---

## 2. QUẢN LÝ VÒNG ĐỜI TUYẾN TÍNH NGHIÊM NGẶT (STRICT LINEAR LIFECYCLE)

Hệ thống phải quản lý trạng thái thực thi dựa trên mô hình **Máy Trạng Thái Hữu Hạn (FSM)** kết hợp với **Đường Ống Tuyến Tính (Linear Pipeline)** tương tự như cơ chế của Android/iOS Lifecycle:

*   **Quy tắc tịnh tiến một chiều (One-Way Progression):** Workflow phải di chuyển theo một đồ thị có hướng cố định từ bước cũ sang bước mới ($A \rightarrow B \rightarrow C$).
*   **Khóa trạng thái quá khứ (State Freezing):** Khi luồng đã chuyển sang thực thi Step $N$, tất cả các Step từ $1$ đến $N-1$ sẽ rơi vào trạng thái `Completed` hoặc `Frozen`. Hệ thống tuyệt đối **không cho phép** kích hoạt ngược lại các bước quá khứ này.
*   **Chặn nhảy cóc (No Short-circuiting):** Hệ thống không cho phép kích hoạt Step $N+2$ nếu Step $N+1$ chưa hoàn thành và phát tín hiệu thành công.
*   **Quản lý trạng thái tại một thời điểm (Single-State Execution):** Tại một thời điểm, chỉ có duy nhất một Step (hoặc một cụm Step song song được định nghĩa trước) được quyền ở trạng thái hoạt động (`Active`). Mọi hành vi cố gắng gọi hàm thực thi hay phát tín hiệu hoàn thành từ một Step không thuộc quyền quản lý hiện tại sẽ bị Engine từ chối và ném lỗi `StateError`.

---

## 3. CÁC CHIẾN LƯỢC THỰC THI (EXECUTION STRATEGIES)

*   **Thực thi Tuần tự (Sequential Execution):** Luồng tổng tự động kích hoạt Step đằng sau ngay sau khi Step đằng trước báo cáo hoàn thành.
*   **Thực thi Tự chủ & Báo cáo (Autonomous Execution):** Kích hoạt một Step phức tạp, Step đó sẽ tự chạy logic nội tại (ví dụ: gọi API 1 $\rightarrow$ API 2 $\rightarrow$ lắng nghe Stream). Khi logic bên trong hoàn thiện hoàn toàn, Step sẽ chủ động phát một tín hiệu (`Complete Signal`) thông qua bộ điều phối (`Completer`) để báo về cho Engine tổng tịnh tiến luồng.
*   **Luồng lồng nhau (Nested Steps/Sub-workflows):** Một Step có thể chứa một nhóm các tác vụ lồng nhau (Sub-workflow) độc lập. Nhóm con này phải tuân thủ đầy đủ các quy tắc thực thi, bắt lỗi, truyền dữ liệu, và quản lý vòng đời như một luồng lớn.

---

## 4. CHIẾN LƯỢC XỬ LÝ KÍCH HOẠT TRÙNG LẶP (CONCURRENCY STRATEGIES)

Khi luồng đang ở trạng thái chạy (`Running`) mà tiếp tục nhận được lệnh kích hoạt (`Start/Trigger`) từ UI hoặc Event ngầm, Package phải cung cấp sẵn 5 cấu hình xử lý xung đột:

1.  **`ignore` (Mặc kệ luồng mới):** Nuốt chửng hoàn toàn lệnh gọi mới. Luồng cũ tiếp tục tịnh tiến bình thường mà không bị ảnh hưởng.
2.  **`cancelExisting` (Hủy cũ - Chạy mới):** Lập tức phát lệnh hủy tối cao lên luồng cũ, đợi giải phóng hoàn toàn tài nguyên mạng/bộ nhớ, reset trạng thái về ban đầu và khởi chạy luồng mới từ đầu.
3.  **`parallel` (Chạy song song cô lập):** Tạo ra một thực thể (Instance) luồng độc lập mới hoàn toàn. Mỗi luồng sở hữu một bộ nhớ (`FlowContext`) riêng biệt, không xâm phạm dữ liệu của nhau.
4.  **`enqueue` (Xếp hàng đợi):** Đưa lệnh gọi mới vào hàng đợi (Queue). Khi luồng cũ kết thúc (dù thành công hay thất bại), luồng tiếp theo trong hàng đợi sẽ tự động kích hoạt.
5.  **`joinOrCreate` (Hợp nhất luồng/Global Shared Flow):** Nếu luồng chưa chạy, tạo phiên xử lý mới. Nếu luồng đang chạy (ví dụ: Global Loading Indicator), không tạo thêm thực thể mới để tránh nhấp nháy UI mà gộp tác vụ mới vào phiên chạy chung này.

---

## 5. QUẢN LÝ THỜI GIAN SỐNG GỘP LUỒNG (JOIN COMPLETION RULES)

Khi áp dụng chiến lược `joinOrCreate` đối với các tài nguyên dùng chung toàn app, thời điểm kết thúc luồng và hạ UI (ví dụ: ẩn Loading) phải tuân thủ theo 3 quy tắc cấu hình ngặt nghèo:

*   **`waitAll` (Đếm tham chiếu):** Phải đợi tất cả các tác vụ tham gia gộp luồng hoàn thành công việc của riêng chúng thì mới chính thức đóng luồng tổng và hạ UI.
*   **`overrideByLatest` (Ưu tiên luồng cuối):** Tác vụ nào kích hoạt sau cùng sẽ giành quyền kiểm soát thời gian sống. Khi tác vụ cuối này xong, luồng tổng sẽ kết thúc và hạ UI ngay lập tức, mặc kệ tác vụ kích hoạt trước đó có đang chạy ngầm tiếp hay không (Đảm bảo trải nghiệm UI không bị ngâm loading quá lâu).
*   **`firstWins` (Bên nào xong trước thắng):** Chỉ cần bất kỳ tác vụ nào trong nhóm gộp hoàn thành trước, luồng tổng lập tức đóng và giải phóng UI cho người dùng.

---

## 6. CƠ CHẾ TRUYỀN DỮ LIỆU & QUẢN LÝ BỘ NHỚ (DATA PIPELINE)

*   **Nhận biết kết quả (Context Awareness):** Cung cấp một bộ nhớ dùng chung (`FlowContext`) xuyên suốt luồng. Các Step chạy phía sau phải có khả năng đọc và hiểu toàn bộ kết quả, trạng thái của các Step đã chạy trước đó để quyết định logic xử lý.
*   **Bảo vệ tính bất biến (Scoped Immutability):** Dữ liệu của các Step trước khi đã ghi vào `FlowContext` thì các Step sau chỉ có quyền đọc (`Read-only`), ngăn chặn tuyệt đối hành vi ghi đè dữ liệu làm sai lệch lịch sử và trạng thái hệ thống.

---

## 7. CƠ CHẾ HỦY BỎ & ĐÓNG VÒNG ĐỜI NGẶT NGHÈO (CANCELLATION & LIFECYCLE)

*   **Hủy trước khi chạy (Pre-start Cancellation):** Nếu lệnh hủy (`Cancel`) được phát ra ngay trước khi luồng kịp khởi chạy, hệ thống phải chặn đứng toàn bộ luồng, không cho phép bất kỳ một Step nào được kích hoạt.
*   **Hủy giữa chừng (Mid-flight Cancellation):** Nếu lệnh hủy phát ra khi luồng đang chạy ở một Step bất kỳ:
    *   Chặn đứng không cho các Step phía sau kích hoạt.
    *   Kích hoạt ngay lập tức hàm dọn dẹp/hủy bỏ (`onDeactivateOrCancel`) của chính Step đang chạy để giải phóng tài nguyên.
*   **Hủy lan truyền (Cascading Cancellation):** Đối với luồng lồng nhau (`Nested Step`), khi Step cha bị hủy hoặc lỗi, lệnh hủy phải tự động lan truyền theo hiệu ứng domino xuống tất cả các Step con nằm sâu nhất bên trong cấu trúc của nó.
*   **Giải phóng tài nguyên tự động (Memory Safety):** Toàn bộ các tác vụ rò rỉ bộ nhớ tiềm ẩn như Unsubscribe Stream, hủy CancelToken của API, đóng kết nối Socket phải được Engine tự động gom và giải phóng hoàn toàn khi luồng kết thúc hoặc bị hủy.

---

## 8. HỆ THỐNG GIÁM SÁT TOÀN CỤC (WORKFLOW INTERCEPTOR)

*   Cung cấp giao thức (`Interface`) đánh chặn độc lập, cho phép lắng nghe sự thay đổi trạng thái của Engine, trạng thái của từng Step, và các hành vi ghi dữ liệu vào `FlowContext` theo thời gian thực.
*   Giúp tách biệt logic nghiệp vụ với logic bổ trợ, phục vụ các tác vụ như: Tự động ghi Log tập trung, đẩy dữ liệu tracking analytics, hoặc dựng màn hình Debug luồng thời gian thực cho nhà phát triển.

---

## 9. STEP CHỜ TƯƠNG TÁC NGƯỜI DÙNG (INTERACTIVE / UI-AWAITING STEP)

**Vấn đề hiện tại:** Engine chỉ có một khái niệm `execute()` chạy-và-trả-kết-quả. Với các Step cần dừng lại chờ người dùng nhập liệu trên UI (ví dụ: một trang form trong wizard) rồi mới tiếp tục, mỗi nơi dùng engine phải tự tay:

```dart
Future<StepResult> execute(context, token) {
  final completer = Completer<StepResult>();
  // lưu completer ra ngoài (field của ViewModel) để UI gọi vào khi user bấm Submit
  _pendingCompleter = completer;
  return completer.future;
}
```

rồi tự expose `createStepCompleter()` / `completeCurrentStep()` thủ công lên ViewModel, tự nối `CancellationToken` để hủy completer khi UI bị đóng, tự đảm bảo không có state check nào ngăn một Step *không* đang active gọi complete. Đây là logic lặp lại y hệt ở mọi flow có step tương tác (ví dụ `signup_steps.dart`), engine không hề biết đến khái niệm "Step này đang chờ input", nên không thể phản ánh nó ra `WorkflowProgress`/`StepStatus`, không thể áp dụng đồng nhất các quy tắc hủy/State Freezing ở Mục 2 và Mục 7.

**Yêu cầu:** Engine phải cung cấp một primitive bậc nhất cho loại Step này (ví dụ `InteractiveStep<TContext, TInput>` hoặc `UserInputStep`), tối thiểu đảm bảo:

*   **Khai báo tường minh:** Step tự khai báo nó là loại "chờ tín hiệu ngoài" thay vì tự chế `Completer` trần trong `execute()`. Engine chịu trách nhiệm tạo/hủy `Completer` nội bộ, Step/ViewModel chỉ cần gọi một API công khai kiểu `runner.submit(stepId, input)` hoặc `runner.fail(stepId, error)` để đẩy luồng đi tiếp.
*   **Trạng thái riêng biệt:** `StepStatus` cần phân biệt được step đang *chạy logic nội bộ* (`running`) với step đang *tạm dừng chờ UI* (ví dụ `awaitingInput`), để `WorkflowProgress`/step indicator phản ánh đúng UX (spinner khác với "đang chờ bạn nhập").
*   **Tuân thủ State Freezing (Mục 2):** Nếu `submit`/`fail` được gọi cho một `stepId` không phải Step đang active hiện tại, Engine phải từ chối và ném `StateError` — nhất quán với quy tắc "Single-State Execution" đã đặt ra cho toàn hệ thống, không phải một cơ chế tách biệt do từng flow tự đảm bảo.
*   **Tự dọn dẹp khi hủy (Mục 7):** Khi `CancellationToken` bị hủy trong lúc Step đang ở trạng thái chờ input, Engine phải tự hoàn tất/loại bỏ `Completer` nội bộ và gọi `onDeactivateOrCancel` — người viết Step không cần tự tay nối `token.onCancel(...)` để tránh leak hoặc treo `Future` vĩnh viễn.

---

## 10. ĐỊNH NGHĨA STEP LINH HOẠT: KẾ THỪA HOẶC HÀM DỰNG (INHERITANCE + FUNCTIONAL CONSTRUCTOR)

**Vấn đề hiện tại:** Cách duy nhất để định nghĩa một Step là tạo hẳn một class kế thừa `WorkflowStep<TContext>` và override `execute()` (và tùy chọn `rollback()`). Với các Step logic đơn giản, chỉ vài dòng gọi API hoặc gán giá trị vào `FlowContext`, việc bắt buộc phải tạo ra một class riêng là dư thừa, làm phình số lượng file/class cho những luồng có nhiều bước nhỏ.

**Yêu cầu:** Song song với cách kế thừa (vẫn phải giữ, dùng cho Step phức tạp cần state/dependency riêng, hoặc cần tái sử dụng ở nhiều luồng), Engine phải hỗ trợ định nghĩa Step bằng cách truyền trực tiếp các hàm xử lý qua constructor/factory, không cần tạo class mới. Tối thiểu gồm:

*   `id` của step.
*   Hàm `execute(context, token) -> FutureOr<StepResult>` truyền vào như một tham số.
*   Hàm `rollback(context) -> FutureOr<void>` truyền vào tùy chọn (không truyền thì coi như không cần rollback).
*   Phải tương thích đầy đủ với mọi cơ chế khác trong tài liệu này (Retry/Timeout decorator, Conditional, Parallel, Nested/Sub-workflow, Interactive step ở Mục 9, Interceptor ở Mục 8...) — tức là step định nghĩa theo kiểu hàm dựng phải cùng implement chung interface/abstract class với step định nghĩa theo kiểu kế thừa, chỉ khác ở cách khởi tạo.

---

## 11. GHI CHÚ PHẠM VI TRIỂN KHAI (IMPLEMENTATION SCOPE NOTE)

Việc triển khai các yêu cầu trên **không bắt buộc phải mở rộng/tương thích ngược** với API hiện tại của `maac_workflow` (`WorkflowStep`, `WorkflowRunner`, `StepResult`, v.v.). Có thể viết lại toàn bộ package từ đầu nếu cách tổ chức code hiện tại không đảm bảo được các yêu cầu đặt ra — miễn logic cuối cùng thỏa mãn đầy đủ nội dung tài liệu này. Các package con phụ thuộc (`maac_workflow` example, `signup_flow`, v.v.) sẽ được cập nhật lại theo API mới sau khi thiết kế được chốt.
