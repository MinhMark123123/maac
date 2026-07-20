import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'signup_context.dart';
import 'signup_view_model.dart';

class SignupFlowPage extends DependencyViewModelWidget<SignupViewModel> {
  const SignupFlowPage({super.key});

  @override
  Widget build(BuildContext context, SignupViewModel viewModel) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        title: const Text('Interactive Signup Workflow Showcase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF16161B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Left panel: Stepper wizard
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              child: StreamDataConsumer<SignupScreen>(
                streamData: viewModel.activeScreen,
                builder: (context, screen) {
                  return Card(
                    color: const Color(0xFF181822),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: _buildScreenContent(context, screen, viewModel),
                    ),
                  );
                },
              ),
            ),
          ),
          // Right panel: Live Console & Status
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF14141B),
                border: Border(left: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal, color: Colors.cyanAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Engine Telemetry Logs',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                        onPressed: viewModel.clearLogs,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0B0E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: StreamDataConsumer<List<String>>(
                        streamData: viewModel.workflowHistory,
                        builder: (context, logs) {
                          if (logs.isEmpty) {
                            return const Center(
                              child: Text('No telemetry events registered.', style: TextStyle(color: Colors.grey)),
                            );
                          }
                          return ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              // Color code tags
                              Color textColor = Colors.greenAccent;
                              if (log.contains('Failure') || log.contains('Error') || log.contains('failed')) {
                                textColor = Colors.redAccent;
                              } else if (log.contains('Rollback')) {
                                textColor = Colors.orangeAccent;
                              } else if (log.contains('Interactive')) {
                                textColor = Colors.purpleAccent;
                              } else if (log.contains('Skip')) {
                                textColor = Colors.grey;
                              } else if (log.contains('[Engine]')) {
                                textColor = Colors.cyanAccent.withOpacity(0.9);
                              } else if (log.contains('Step')) {
                                textColor = Colors.white70;
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: textColor,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenContent(BuildContext context, SignupScreen screen, SignupViewModel viewModel) {
    switch (screen) {
      case SignupScreen.welcome:
        return _buildWelcome(viewModel);
      case SignupScreen.basicInfo:
        return _buildBasicInfo(viewModel);
      case SignupScreen.loadingBackend:
        return _buildLoading(viewModel);
      case SignupScreen.optionalDetails:
        return _buildOptionalDetails(viewModel);
      case SignupScreen.reviewScreen:
        return _buildReview(viewModel);
      case SignupScreen.success:
        return _buildSuccess(viewModel);
      case SignupScreen.failed:
        return _buildFailed(viewModel);
    }
  }

  Widget _buildWelcome(SignupViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle_outlined, size: 80, color: Colors.cyanAccent),
        const SizedBox(height: 16),
        const Text(
          'Interactive Stepper Wizard',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'This wizard simulates interactive user input screens driven by the workflow pipeline. We can enable/disable steps, force step failures to trigger transactions and rollback account deletion.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        // Toggle items before starting
        StreamDataConsumer<bool>(
          streamData: viewModel.needsOptional,
          builder: (context, opt) {
            return SwitchListTile(
              title: const Text('Enable Step 2: Avatar & Referral (Conditional Step)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('If off, this step will be marked Skipped by the engine.', style: TextStyle(color: Colors.grey)),
              value: opt,
              onChanged: viewModel.setNeedsOptional,
              activeColor: Colors.cyanAccent,
            );
          },
        ),
        StreamDataConsumer<bool>(
          streamData: viewModel.forceFail,
          builder: (context, fail) {
            return SwitchListTile(
              title: const Text('Force Register API to Fail (Trigger LIFO Rollback)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Forces final step to crash. This deletes the created user account.', style: TextStyle(color: Colors.grey)),
              value: fail,
              onChanged: viewModel.setForceFail,
              activeColor: Colors.cyanAccent,
            );
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: viewModel.startFlow,
          child: const Text('Launch Signup Flow', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(SignupViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWizardHeader(1, 'Basic Credentials', 'Input email & password to register.'),
        const SizedBox(height: 24),
        TextField(
          controller: viewModel.emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email Address',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: viewModel.passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
        ),
        const Spacer(),
        _buildNavigationRow(viewModel),
      ],
    );
  }

  Widget _buildLoading(SignupViewModel viewModel) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent)),
        SizedBox(height: 24),
        Text('Backend Orchestration Running...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('The workflow runner is performing background API transaction checks.', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildOptionalDetails(SignupViewModel viewModel) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWizardHeader(2, 'Personal Profile (Conditional Step)', 'Select a cute avatar and enter code.'),
            const SizedBox(height: 20),
            const Text('Choose Avatar:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _avatarButton('🐱', 'Cat', viewModel, setState),
                _avatarButton('🐶', 'Dog', viewModel, setState),
                _avatarButton('🦊', 'Fox', viewModel, setState),
                _avatarButton('🦁', 'Lion', viewModel, setState),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: viewModel.referralController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Referral Code (Optional)',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
            ),
            const Spacer(),
            _buildNavigationRow(viewModel),
          ],
        );
      },
    );
  }

  Widget _avatarButton(String emoji, String name, SignupViewModel viewModel, void Function(void Function()) setState) {
    final isSelected = viewModel.selectedAvatar == emoji;
    return GestureDetector(
      onTap: () {
        setState(() {
          viewModel.selectedAvatar = emoji;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent.withOpacity(0.15) : const Color(0xFF22222E),
          border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(color: isSelected ? Colors.cyanAccent : Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(SignupViewModel viewModel) {
    final ctx = viewModel.context;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWizardHeader(3, 'Final Submission', 'Review account credentials and finalize registration.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _infoRow('Email Address:', ctx.email),
              _infoRow('Assigned Database ID:', ctx.userId ?? 'Waiting...'),
              _infoRow('Chosen Avatar:', ctx.avatarUrl ?? 'None selected'),
              _infoRow('Referral Applied:', ctx.referralCode ?? 'None applied'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        StreamDataConsumer<bool>(
          streamData: viewModel.forceFail,
          builder: (context, fail) {
            return SwitchListTile(
              title: const Text('Force Register API to Fail', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: const Text('Will trigger LIFO Rollback. Watch it delete the user database ID!', style: TextStyle(color: Colors.grey, fontSize: 12)),
              value: fail,
              onChanged: viewModel.setForceFail,
              activeColor: Colors.cyanAccent,
            );
          },
        ),
        const Spacer(),
        _buildNavigationRow(viewModel, isFinal: true),
      ],
    );
  }

  Widget _buildSuccess(SignupViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 80, color: Colors.greenAccent),
        const SizedBox(height: 24),
        const Text('Signup Flow Succeeded!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('User database record successfully completed with ID: ${viewModel.context.userId}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(180, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: viewModel.reset,
          child: const Text('Go Home', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFailed(SignupViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
        const SizedBox(height: 24),
        const Text('Signup Flow Failed / Cancelled!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'The workflow halted. Any database account creation was fully deleted and rolled back as verified in telemetry.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(180, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: viewModel.reset,
          child: const Text('Go Home', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildWizardHeader(int step, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP $step OF 3', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w600, letterSpacing: 1.2, fontSize: 12)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 12),
        const Divider(color: Colors.white10),
      ],
    );
  }

  Widget _buildNavigationRow(SignupViewModel viewModel, {bool isFinal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: viewModel.cancelWorkflow,
          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
          label: const Text('Abort Flow', style: TextStyle(color: Colors.redAccent)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isFinal ? Colors.greenAccent : Colors.cyanAccent,
            foregroundColor: Colors.black,
            minimumSize: const Size(140, 46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: viewModel.submitCurrentStep,
          child: Text(
            isFinal ? 'Final Submit' : 'Next Step',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
