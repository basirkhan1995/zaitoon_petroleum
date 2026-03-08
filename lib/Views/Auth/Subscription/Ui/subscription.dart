import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/toast.dart';
import 'package:zaitoon_petroleum/Views/Auth/Subscription/bloc/subscription_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Features/Date/gregorian_date_picker.dart';
import '../../../../Features/Widgets/outline_button.dart';
import '../../../../Features/Widgets/textfield_entitled.dart';
import '../model/sub_model.dart';
import 'no_subscription.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoadedState) {
          final subscriptions = state.subs;

          // If no subscriptions, show no subscription view
          if (subscriptions.isEmpty) {
            return const NoSubscriptionView();
          }

          // Get the first (or current) subscription
          final currentSub = subscriptions.first;

          return ResponsiveLayout(
            mobile: _MobileContent(subscription: currentSub),
            tablet: _TabletContent(subscription: currentSub),
            desktop: _DesktopContent(subscription: currentSub),
          );
        } else if (state is SubscriptionLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is SubscriptionErrorState) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 20),
                  ZOutlineButton(
                    label: const Text('Retry'),
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
                    },
                    icon: Icons.refresh,
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// Mobile Version
class _MobileContent extends StatelessWidget {
  final SubscriptionModel subscription;

  const _MobileContent({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _SubscriptionDetails(subscription: subscription),
      ),
    );
  }
}

// Tablet Version
class _TabletContent extends StatelessWidget {
  final SubscriptionModel subscription;

  const _TabletContent({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 600,
            child: _SubscriptionDetails(subscription: subscription),
          ),
        ),
      ),
    );
  }
}

// Desktop Version
class _DesktopContent extends StatelessWidget {
  final SubscriptionModel subscription;

  const _DesktopContent({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SizedBox(
            width: 600,
            child: _SubscriptionDetails(subscription: subscription),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionDetails extends StatelessWidget {
  final SubscriptionModel subscription;

  const _SubscriptionDetails({required this.subscription});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool get _isExpired {
    if (subscription.subExpireDate == null) return false;
    return subscription.subExpireDate!.isBefore(DateTime.now());
  }

  void _showUpdateForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _UpdateSubscriptionForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _isExpired;
    final expireDate = _formatDate(subscription.subExpireDate);
    final entryDate = _formatDate(subscription.subEntryDate);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Subscription",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isExpired ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            isExpired ? "Expired" : "Activated",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ZOutlineButton(
                    label: const Text("Update"),
                    icon: Icons.refresh,
                    height: 40,
                    isActive: true,
                    onPressed: () => _showUpdateForm(context),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// SUBSCRIPTION KEY
              Text(
                "Subscription Key",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  subscription.subKey ?? "N/A",
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// EXPIRY DATE
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: "Expiry Date",
                value: expireDate,
                isExpired: isExpired,
              ),

              const SizedBox(height: 18),

              /// ENTRY DATE
              _buildInfoRow(
                icon: Icons.date_range,
                label: "Entry Date",
                value: entryDate,
              ),

              const SizedBox(height: 20),

              /// EXPIRED WARNING
              if (isExpired)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: .3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Your subscription has expired. Please update it.",
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isExpired = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isExpired ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Update Subscription Form
class _UpdateSubscriptionForm extends StatefulWidget {
  const _UpdateSubscriptionForm();

  @override
  State<_UpdateSubscriptionForm> createState() => _UpdateSubscriptionFormState();
}

class _UpdateSubscriptionFormState extends State<_UpdateSubscriptionForm> {
  final _oldKeyController = TextEditingController();
  final _newKeyController = TextEditingController();
  final _expireDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showDatePicker() async {
    DateTime? initialDate;

    if (_expireDateController.text.isNotEmpty) {
      try {
        final parts = _expireDateController.text.split('-');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        } else {
          initialDate = DateTime.now();
        }
      } catch (e) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    await showDialog(
      context: context,
      builder: (context) => GregorianDatePicker(
        initialDate: initialDate,
        onDateSelected: (selectedDate) {
          setState(() {
            _expireDateController.text = _formatDate(selectedDate);
          });
        },
        minYear: 2020,
        maxYear: 2030,
        disablePastDates: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionSuccessState) {
            Navigator.pop(context);
            ToastManager.show(
              context: context,
              title: "Success",
              message: "Subscription updated successfully!",
              type: ToastType.success,
            );
            // Refresh subscription data
            context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
          } else if (state is SubscriptionErrorState) {
            ToastManager.show(
              context: context,
              title: "Error",
              message: state.message,
              type: ToastType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SubscriptionLoadingState;

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Update Subscription',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ZTextFieldEntitled(
                  title: 'Old Key',
                  hint: 'Enter your current key',
                  controller: _oldKeyController,
                  icon: Icons.vpn_key,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter old key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ZTextFieldEntitled(
                  title: 'New Subscription Key',
                  hint: 'Enter your new key',
                  controller: _newKeyController,
                  icon: Icons.vpn_key,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter new key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showDatePicker,
                  child: AbsorbPointer(
                    child: ZTextFieldEntitled(
                      title: 'Expiry Date',
                      hint: 'Tap to select date',
                      controller: _expireDateController,
                      icon: Icons.calendar_today,
                      isRequired: true,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select expiry date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ZOutlineButton(
                        label: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ZOutlineButton(
                        label: isLoading
                            ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(),
                        )
                            : const Text('Update'),
                        onPressed: isLoading ? null : _updateSubscription,
                        isActive: true,
                        icon: isLoading ? null : Icons.update,
                        disable: isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateSubscription() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SubscriptionBloc>().add(
        AddOrUpdateSubscriptionEvent(
          _newKeyController.text,
          _oldKeyController.text,
          _expireDateController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _oldKeyController.dispose();
    _newKeyController.dispose();
    _expireDateController.dispose();
    super.dispose();
  }
}