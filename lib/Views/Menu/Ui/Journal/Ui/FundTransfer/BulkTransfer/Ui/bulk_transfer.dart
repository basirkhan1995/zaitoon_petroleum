import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';
import '../model/transfer_model.dart';

Future<void> showTransferDialog(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<TransferBloc>()..add(InitializeTransferEvent()),
      child: _TransferDialog(),
    ),
  );
}

class _TransferDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(18),
        child: BlocBuilder<TransferBloc, TransferState>(
          builder: (context, state) {
            if (state is! TransferLoadedState) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Fund Transfer", style: Theme.of(context).textTheme.titleLarge),

                const SizedBox(height: 20),
                _buildSection(context, state, true),

                const SizedBox(height: 20),
                _buildSection(context, state, false),

                const SizedBox(height: 20),
                Text("Debit: ${state.totalDebit}    Credit: ${state.totalCredit}"),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel")),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        context.read<TransferBloc>().add(SaveTransferEvent());
                        Navigator.pop(context);
                      },
                      child: Text("Submit"),
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, TransferLoadedState state, bool isDebit) {
    final list = isDebit ? state.debits : state.credits;
    final title = isDebit ? "Debit Accounts" : "Credit Accounts";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                if (isDebit) {
                  context.read<TransferBloc>().add(AddDebitRowEvent());
                } else {
                  context.read<TransferBloc>().add(AddCreditRowEvent());
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 8),

        Column(
          children: list.map((e) => _buildRow(context, e, isDebit)).toList(),
        )
      ],
    );
  }

  Widget _buildRow(BuildContext context, TransferEntry entry, bool isDebit) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: () async {
              // Replace with your account selector
              final acc = await Future.value(null);
              if (acc != null) {
                context.read<TransferBloc>().add(UpdateEntryEvent(
                  id: entry.rowId,
                  isDebit: isDebit,
                  accountName: acc.accName,
                  accountNumber: acc.accountNumber,
                  currency: acc.ccySymbol,
                ));
              }
            },
            child: Container(
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Text(entry.accountName ?? "Select Account"),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: entry.amount == 0 ? "" : entry.amount.toString(),
            decoration: InputDecoration(border: OutlineInputBorder()),
            onChanged: (val) {
              context.read<TransferBloc>().add(UpdateEntryEvent(
                id: entry.rowId,
                isDebit: isDebit,
                amount: double.tryParse(val) ?? 0.0,
              ));
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          flex: 1,
          child: Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(entry.currency ?? "---"),
          ),
        ),

        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<TransferBloc>().add(RemoveEntryEvent(
              id: entry.rowId,
              isDebit: isDebit,
            ));
          },
        )
      ],
    );
  }
}
