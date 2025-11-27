import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

class PrinterCubit extends Cubit<Printer?> {
  PrinterCubit() : super(null);

  void setPrinter(Printer printer) {
    emit(printer);
  }
}