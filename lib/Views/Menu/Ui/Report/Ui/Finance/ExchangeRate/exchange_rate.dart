import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/features/currency_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ExchangeRate/model/rate_report_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ExchangeRate/bloc/fx_rate_report_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../../../../Features/Date/z_generic_date.dart';
class FxRateReportView extends StatelessWidget {
  const FxRateReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {

  String? _selectedFromCurrency;
  String? _selectedToCurrency;


  String fromDate = DateTime.now().subtract(Duration(days: 7)).toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();
  Jalali shamsiFromDate = DateTime.now().subtract(Duration(days: 7)).toAfghanShamsi;
  Jalali shamsiToDate = DateTime.now().toAfghanShamsi;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {

    super.dispose();
  }



  void _onFilterChanged(BuildContext context) {
    context.read<FxRateReportBloc>().add(
      LoadFxRateReportEvent(
        fromDate: fromDate,
        toDate: toDate,
        fromCcy: _selectedFromCurrency,
        toCcy: _selectedToCurrency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("FX Rate"),
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Filters
            _buildFilterSection(context),
            const SizedBox(height: 30),

            // Report Content
            Expanded(
              child: BlocConsumer<FxRateReportBloc, FxRateReportState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is FxRateReportLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FxRateReportErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is FxRateReportLoadedState) {
                    return state.rates.isEmpty
                        ? const Center(
                      child: Text(
                        'No exchange rate data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : _buildReportTable(state.rates);
                  }

                  return const Center(
                    child: Text(
                      'Select date range and currencies to load report',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              Expanded(

                child: ZDatePicker(
                  label: tr.fromDate,
                  value: fromDate,
                  onDateChanged: (v) {
                    setState(() {
                      fromDate = v;
                      shamsiFromDate = v.toAfghanShamsi;
                    });
                    _onFilterChanged(context);
                  },
                ),
              ),
              Expanded(
                child: ZDatePicker(
                  label: tr.toDate,
                  value: toDate,
                  onDateChanged: (v) {
                    setState(() {
                      toDate = v;
                      shamsiToDate = v.toAfghanShamsi;
                    });
                    _onFilterChanged(context);
                  },
                ),
              ),

              Expanded(
                child: CurrencyDropdown(
                    title: "From Currency",
                    isMulti: false,
                    onSingleChanged: (e){
                      setState(() {
                        _selectedFromCurrency = e?.ccyCode;
                      });
                    },
                    onMultiChanged: (e){

                    }),
              ),
              Expanded(
                child: CurrencyDropdown(
                    title: "To Currency",
                    isMulti: false,
                    onSingleChanged: (e){
                      setState(() {
                        _selectedToCurrency = e?.ccyCode;
                      });
                    },
                    onMultiChanged: (e){

                    }),
              ),
              ZOutlineButton(
                width: 120,
                  icon: Icons.call_to_action_outlined,
                  label: Text("Apply"),
                onPressed: () => _onFilterChanged(context),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable(List<ExchangeRateReportModel> rates) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                _buildTableHeader('Date', flex: 1),
                _buildTableHeader('From Currency', flex: 2),
                _buildTableHeader('To Currency', flex: 2),
                _buildTableHeader('Exchange Rate', flex: 1),
                _buildTableHeader('Average Rate', flex: 1),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.separated(
              itemCount: rates.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
              itemBuilder: (context, index) {
                final rate = rates[index];
                return _buildTableRow(rate);
              },
            ),
          ),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Records: ${rates.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Last Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTableRow(ExchangeRateReportModel rate) {
    final isSameCurrency = rate.isSameCurrency;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSameCurrency ? Colors.amber[50] : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              DateFormat('MMM dd, yyyy').format(rate.rateDate),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildCurrencyInfo(
              code: rate.fromCode,
              name: rate.fromName,
              country: rate.fromCountry,
              symbol: rate.fromSymbol,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildCurrencyInfo(
              code: rate.toCode,
              name: rate.toName,
              country: rate.toCountry,
              symbol: rate.toSymbol,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              rate.displayRate,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              rate.displayAvgRate,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInfo({
    required String code,
    required String name,
    required String country,
    required String symbol,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                code,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              symbol,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          country,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}