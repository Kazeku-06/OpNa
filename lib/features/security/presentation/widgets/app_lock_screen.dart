import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final bool isSetup;

  const AppLockScreen({
    super.key,
    required this.onUnlocked,
    this.isSetup = false,
  });

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _hasError = false;

  static const int pinLength = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),

              Text(
                widget.isSetup
                    ? (_isConfirming ? 'Confirm PIN' : 'Set up PIN')
                    : 'Enter PIN to unlock',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              if (widget.isSetup && !_isConfirming)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Choose a 4-digit PIN to secure your notes',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 48),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pinLength, (index) {
                  final currentPin = _isConfirming ? _confirmPin : _enteredPin;
                  final isFilled = index < currentPin.length;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: _hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              if (_hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    widget.isSetup
                        ? 'PINs do not match. Try again.'
                        : 'Incorrect PIN. Try again.',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 48),

              // Number pad
              _buildNumberPad(),

              const SizedBox(height: 24),

              if (!widget.isSetup)
                TextButton(
                  onPressed: () {
                    // In a real app, this might show recovery options
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PIN recovery not implemented in demo'),
                      ),
                    );
                  },
                  child: const Text('Forgot PIN?'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Empty space
            _buildNumberButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Center(
          child: Text(
            number,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: _onBackspacePressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: const Center(child: Icon(Icons.backspace_outlined)),
      ),
    );
  }

  void _onNumberPressed(String number) {
    HapticFeedback.lightImpact();

    setState(() {
      _hasError = false;

      if (_isConfirming) {
        if (_confirmPin.length < pinLength) {
          _confirmPin += number;
          if (_confirmPin.length == pinLength) {
            _validateConfirmPin();
          }
        }
      } else {
        if (_enteredPin.length < pinLength) {
          _enteredPin += number;
          if (_enteredPin.length == pinLength) {
            if (widget.isSetup) {
              _moveToConfirm();
            } else {
              _validatePin();
            }
          }
        }
      }
    });
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();

    setState(() {
      _hasError = false;

      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      }
    });
  }

  void _moveToConfirm() {
    setState(() {
      _isConfirming = true;
      _confirmPin = '';
    });
  }

  void _validateConfirmPin() {
    if (_enteredPin == _confirmPin) {
      // Save PIN and unlock
      _savePinAndUnlock();
    } else {
      setState(() {
        _hasError = true;
        _isConfirming = false;
        _enteredPin = '';
        _confirmPin = '';
      });
    }
  }

  void _validatePin() {
    // In a real app, this would check against stored PIN
    // For demo purposes, we'll accept any 4-digit PIN
    widget.onUnlocked();
  }

  void _savePinAndUnlock() {
    // In a real app, this would securely store the PIN
    // For demo purposes, we'll just unlock
    widget.onUnlocked();
  }
}
