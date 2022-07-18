import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber/brand_colors.dart';
import 'package:uber/datamodels/address.dart';
import 'package:uber/datamodels/prediction.dart';
import 'package:uber/dataproviders/appdata.dart';
import 'package:uber/globalvariable.dart';
import 'package:uber/helpers/requesthelper.dart';
import 'package:uber/widgets/ProgressDialog.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  PredictionTile({required this.prediction});

  void getPlaceDetail(String placeId, context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: '     Veuillez patienter',
            ));
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    Navigator.pop(context);
    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      Address thisPlace = Address(
          placeId: '',
          latitude: 0,
          longitude: 0,
          placeName: '',
          placeFormattedAddress: '');
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeId;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updatedestinationAddress(thisPlace);

      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceDetail(prediction.placeId, context);
      },
      style: TextButton.styleFrom(
          padding: EdgeInsets.all(0), primary: BrandColors.colorDimText),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                Icon(Icons.location_on, color: BrandColors.colorDimText),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        prediction.mainText,
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        prediction.secondaryText,
                        style: TextStyle(
                            fontSize: 12, color: BrandColors.colorDimText),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }
}
