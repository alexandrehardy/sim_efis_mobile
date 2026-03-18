import 'package:flutter/material.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/text_style.dart';

class EfisPageButton extends StatelessWidget {
  final TextAlign align;
  final String text;
  final EfisPage function;
  final SelectedPage page;
  const EfisPageButton({
    Key? key,
    required this.text,
    required this.function,
    required this.align,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UiState>(
        initialData: UiStateController.state,
        stream: UiStateController.stream,
        builder: (BuildContext context, snapshot) {
          EfisPage activePage = (page == SelectedPage.first)
              ? snapshot.requireData.firstPage
              : snapshot.requireData.secondPage;
          return TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all((activePage == function)
                  ? Colors.green[900]
                  : Colors.black45),
              side: WidgetStateProperty.all(
                const BorderSide(
                  color: Colors.grey,
                ),
              ),
              shape: WidgetStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              UiStateController.setEfisPage(function, page);
            },
            child: SizedBox(
              width: 70,
              child: Text(
                text,
                style: EfisStyle.efisPageButtonStyle,
                textAlign: align,
                maxLines: 1,
              ),
            ),
          );
        });
  }
}
