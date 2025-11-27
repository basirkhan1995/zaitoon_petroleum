import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';

class PaperSizeCubit extends Cubit<PdfPageFormat> {
  PaperSizeCubit() : super(PdfPageFormat.a4);

  void setPaperSize(PdfPageFormat size) {
    emit(size);
  }
}