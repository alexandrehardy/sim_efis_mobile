//ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/logs.dart';

class Coordinate {
  final double latitude;
  final double longitude;
  final double slippyX;
  final double slippyY;

  static double computeSlippyX({
    required double latitude,
    required double longitude,
  }) {
    double slippyX = ((longitude + 180.0) / 360.0);
    return slippyX;
  }

  static double computeSlippyY({
    required double latitude,
    required double longitude,
  }) {
    double latRadian = latitude / 180.0 * pi;
    double slippyY =
        (1 - (log(tan(latRadian) + 1.0 / cos(latRadian)) / pi)) / 2.0;
    return slippyY;
  }

  const Coordinate({
    required this.latitude,
    required this.longitude,
    required this.slippyX,
    required this.slippyY,
  });

  factory Coordinate.gps({
    required latitude,
    required longitude,
  }) {
    double slippyX = computeSlippyX(latitude: latitude, longitude: longitude);
    double slippyY = computeSlippyY(latitude: latitude, longitude: longitude);
    return Coordinate(
      latitude: latitude,
      longitude: longitude,
      slippyX: slippyX,
      slippyY: slippyY,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'long': longitude,
    };
  }

  static Coordinate fromJson(Map<String, dynamic> json) {
    return Coordinate.gps(
      latitude: json['lat'] as double,
      longitude: json['long'] as double,
    );
  }
}

enum LimitDatum {
  ground,
  meanSeaLevel,
  standard,
}

class AirspaceLimit {
  final double feet;
  final LimitDatum datum;

  const AirspaceLimit({
    required this.feet,
    required this.datum,
  });

  Map<String, dynamic> toJson() {
    return {
      'ft': feet,
      'd': datum.index,
    };
  }

  static AirspaceLimit fromJson(Map<String, dynamic> json) {
    return AirspaceLimit(
      feet: json['ft'] as double,
      datum: LimitDatum.values[json['d'] as int],
    );
  }

  @override
  String toString() {
    switch (datum) {
      case LimitDatum.ground:
        if (feet.toInt() == 0) {
          return 'GND';
        }
        return '${feet.toInt()} AGL';
      case LimitDatum.meanSeaLevel:
        return '${feet.toInt()} ALT';
      case LimitDatum.standard:
        int flightLevel = feet.toInt() ~/ 100;
        if (flightLevel < 10) {
          return 'FL00$flightLevel';
        }
        if (flightLevel < 100) {
          return 'FL0$flightLevel';
        }
        return 'FL$flightLevel';
    }
  }
}

enum IcaoClass {
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  SUA,
  Unknown,
}

enum AirspaceType {
  Other,
  Restricted,
  Danger,
  Prohibited,
  CTR,
  TMZ,
  RMZ,
  TMA,
  TRA,
  TSA,
  FIR,
  UIR,
  ADIZ,
  ATZ,
  MATZ,
  AWY,
  MTR,
  AlertArea,
  WarningArea,
  ProtectedArea,
  HTZ,
  GlidingSector,
  TRP,
  TIZ,
  TIA,
  MTA,
  CTA,
  ACC,
  AerialSporting,
  LowOverflyRestriction,
}

enum AirportType {
  AirportCivilOrMilitary,
  GliderSite,
  CivilAirfield,
  InternationalAirport,
  HeliportMilitary,
  MilitaryAerodrome,
  UltraLightFlyingSite,
  HeliportCivil,
  AerodromeClosed,
  AirportAirfieldIFR,
  AirfieldWater,
  LandingStrip,
  AgriculturalLandingStrip,
  Altiport,
}

enum AirportTrafficType {
  VFR,
  IFR,
  BOTH,
}

enum FrequencyType {
  Approach,
  APRON,
  Arrival,
  Center,
  CTAF,
  Delivery,
  Departure,
  FIS,
  Gliding,
  Ground,
  Info,
  Multicom,
  Unicom,
  Radar,
  Tower,
  ATIS,
  Radio,
  Other,
  AIRMET,
  AWOS,
  Lights,
  VOLMET,
  NotSpecified,
}

enum TurnDirection {
  Right,
  Left,
  Both,
}

enum NavAidType {
  DME,
  TACAN,
  NDB,
  VOR,
  VOR_DME,
  VORTAC,
  DVOR,
  DVOR_DME,
  DVORTAC,
}

class Airspace {
  final String id;
  final bool reverseWinding;
  final List<Coordinate> airspace;
  final AirspaceLimit lowerLimit;
  final AirspaceLimit upperLimit;
  final String name;
  final IcaoClass icaoClass;
  final AirspaceType type;
  final double area;
  final Coordinate centre;
  final List<Frequency> frequencies;
  int minZoom = 0;

  Airspace({
    required this.id,
    required this.name,
    required this.airspace,
    required this.lowerLimit,
    required this.upperLimit,
    required this.type,
    required this.icaoClass,
    required this.reverseWinding,
    required this.area,
    required this.centre,
    required this.frequencies,
  });

  String get filename => '$id.air';
  static String getFileName(String id) => '$id.air';

  int computeMinZoom() {
    int zoom = 0;
    // TODO: This is degrees, adjust for whatever area is.
    double compensation = 0.2;
    double scale = 1.0 / pow(2.0, zoom.toDouble()) * compensation;
    double zoomArea = 360 * scale * 180 * scale;
    while (zoomArea > area) {
      zoom = zoom + 1;
      scale = 1.0 / pow(2.0, zoom.toDouble()) * compensation;
      zoomArea = 360 * scale * 180 * scale;
    }
    return zoom;
  }

  AirspaceWithZoom airspaceWithZoom() {
    int minZoom = computeMinZoom();
    this.minZoom = minZoom;
    return AirspaceWithZoom(minZoom: minZoom, id: id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reverseWind': reverseWinding,
      'airspace': airspace.map((e) => e.toJson()).toList(),
      'lower': lowerLimit.toJson(),
      'upper': upperLimit.toJson(),
      'name': name,
      'icao': icaoClass.index,
      'type': type.index,
      'area': area,
      'centre': centre,
      'frequencies': frequencies.map((e) => e.toJson()).toList(),
    };
  }

  static Airspace fromJson(Map<String, dynamic> json) {
    return Airspace(
      id: json['id'] as String,
      name: json['name'] as String,
      lowerLimit: AirspaceLimit.fromJson(json['lower'] as Map<String, dynamic>),
      upperLimit: AirspaceLimit.fromJson(json['upper'] as Map<String, dynamic>),
      reverseWinding: json['reverseWind'] as bool,
      icaoClass: IcaoClass.values[json['icao'] as int],
      type: AirspaceType.values[json['type'] as int],
      area: json['area'] as double,
      airspace: (json['airspace'] as List<dynamic>)
          .map((e) => Coordinate.fromJson(e as Map<String, dynamic>))
          .toList(),
      centre: Coordinate.fromJson(json['centre'] as Map<String, dynamic>),
      frequencies: (json['frequencies'] as List<dynamic>)
          .map((e) => Frequency.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NavAid {
  final String id;
  final NavAidType type;
  final String identifier;
  final String country;
  final Coordinate location;
  final double elevation;
  final bool alignedTrueNorth;
  final String? channel;
  final Frequency frequency;
  final double? range; // Always nautical miles
  final double magneticDeclination;

  const NavAid({
    required this.id,
    required this.type,
    required this.identifier,
    required this.country,
    required this.location,
    required this.elevation,
    required this.alignedTrueNorth,
    required this.channel,
    required this.frequency,
    required this.range,
    required this.magneticDeclination, // Always nautical miles
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'identifier': identifier,
      'country': country,
      'location': location.toJson(),
      'elevation': elevation,
      'alignedTrueNorth': alignedTrueNorth,
      'channel': channel,
      'frequency': frequency.toJson(),
      'range': range,
      'magneticDeclination': magneticDeclination,
    };
  }

  factory NavAid.fromJson(Map<String, dynamic> json) {
    return NavAid(
      id: json['id'] as String,
      type: NavAidType.values[json['type'] as int],
      identifier: json['identifier'] as String,
      country: json['country'] as String,
      location: Coordinate.fromJson(json['location'] as Map<String, dynamic>),
      elevation: json['elevation'] as double,
      alignedTrueNorth: json['alignedTrueNorth'] as bool,
      channel: json['channel'] as String?,
      frequency: Frequency.fromJson(json['frequency'] as Map<String, dynamic>),
      range: json['range'] as double?,
      magneticDeclination: json['magneticDeclination'] as double,
    );
  }
}

class ReportingPoint {
  final String id;
  final String name;
  final bool compulsory;
  final String country;
  final Coordinate location;
  final double elevation;
  final List<String> airports;

  const ReportingPoint({
    required this.id,
    required this.name,
    required this.compulsory,
    required this.country,
    required this.location,
    required this.elevation,
    required this.airports,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'compulsory': compulsory,
      'country': country,
      'location': location.toJson(),
      'elevation': elevation,
      'airports': airports,
    };
  }

  factory ReportingPoint.fromJson(Map<String, dynamic> json) {
    return ReportingPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      compulsory: json['compulsory'] as bool,
      country: json['country'] as String,
      location: Coordinate.fromJson(json['location'] as Map<String, dynamic>),
      elevation: json['elevation'] as double,
      airports: (json['airports'] as List<dynamic>).cast<String>(),
    );
  }
}

class AirportImage {
  final String id;
  final String airportId;
  final String description;

  const AirportImage({
    required this.id,
    required this.description,
    required this.airportId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'airportId': airportId,
    };
  }

  factory AirportImage.fromJson(Map<String, dynamic> json) {
    return AirportImage(
      id: json['id'] as String,
      description: json['description'] as String,
      airportId: json['airportId'] as String,
    );
  }
}

class Frequency {
  final FrequencyType type;
  final String value;

  const Frequency({
    required this.type,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'value': value,
    };
  }

  factory Frequency.fromJson(Map<String, dynamic> json) {
    return Frequency(
      type: FrequencyType.values[json['type'] as int],
      value: json['value'] as String,
    );
  }
}

class Runway {
  final String designator;
  final int trueHeading;
  final bool mainRunway;
  final bool landingOnly;
  final bool takeOffOnly;
  final AirportTrafficType trafficType;
  final TurnDirection turnDirection;
  final int length;
  final int width;

  const Runway({
    required this.designator,
    required this.trueHeading,
    required this.mainRunway,
    required this.landingOnly,
    required this.takeOffOnly,
    required this.trafficType,
    required this.turnDirection,
    required this.length,
    required this.width,
  });

  Map<String, dynamic> toJson() {
    return {
      'designator': designator,
      'trueHeading': trueHeading,
      'mainRunway': mainRunway,
      'landingOnly': landingOnly,
      'takeOffOnly': takeOffOnly,
      'trafficType': trafficType.index,
      'turnDirection': turnDirection.index,
      'length': length,
      'width': width,
    };
  }

  factory Runway.fromJson(Map<String, dynamic> json) {
    return Runway(
      designator: json['designator'] as String,
      trueHeading: json['trueHeading'] as int,
      mainRunway: json['mainRunway'] as bool,
      landingOnly: json['landingOnly'] as bool,
      takeOffOnly: json['takeOffOnly'] as bool,
      trafficType: AirportTrafficType.values[json['trafficType'] as int],
      turnDirection: TurnDirection.values[json['turnDirection'] as int],
      length: json['length'] as int,
      width: json['width'] as int,
    );
  }
}

class Airport {
  final String id;
  final String name;
  final String? icaoCode;
  final String? iataCode;
  final String? altIdentifier;
  final String country;
  final Coordinate location;
  final double elevation; // in feet
  final AirportType type; // 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
  final double magneticDeclination;
  final bool ppr;
  final bool private;
  final bool skydiveActivity;
  final List<AirportImage> images;
  final List<Frequency> frequencies;
  final List<Runway> runways;

  const Airport({
    required this.id,
    required this.name,
    this.icaoCode,
    this.iataCode,
    this.altIdentifier,
    required this.country,
    required this.location,
    required this.elevation,
    required this.type,
    required this.magneticDeclination,
    required this.ppr,
    required this.private,
    required this.skydiveActivity,
    required this.images,
    required this.frequencies,
    required this.runways,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icaoCode': icaoCode,
      'iataCode': iataCode,
      'altIdentifier': altIdentifier,
      'country': country,
      'location': location.toJson(),
      'elevation': elevation,
      'type': type.index,
      'magneticDeclination': magneticDeclination,
      'ppr': ppr,
      'private': private,
      'skydiveActivity': skydiveActivity,
      'images': images.map((e) => e.toJson()).toList(),
      'frequencies': frequencies.map((e) => e.toJson()).toList(),
      'runways': runways.map((e) => e.toJson()).toList(),
    };
  }

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'] as String,
      name: json['name'] as String,
      icaoCode: json['icaoCode'] as String?,
      iataCode: json['iataCode'] as String?,
      altIdentifier: json['altIdentifier'] as String?,
      country: json['country'] as String,
      location: Coordinate.fromJson(json['location'] as Map<String, dynamic>),
      elevation: json['elevation'] as double,
      type: AirportType.values[json['type'] as int],
      magneticDeclination: json['magneticDeclination'] as double,
      ppr: json['ppr'] as bool,
      private: json['private'] as bool,
      skydiveActivity: json['skydiveActivity'] as bool,
      images: (json['images'] as List<dynamic>)
          .map((e) => AirportImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      frequencies: (json['frequencies'] as List<dynamic>)
          .map((e) => Frequency.fromJson(e as Map<String, dynamic>))
          .toList(),
      runways: (json['runways'] as List<dynamic>)
          .map((e) => Runway.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AltitudeDatumResponse {
  final int referenceDatum;
  final int unit;
  final int value;

  const AltitudeDatumResponse({
    required this.referenceDatum,
    required this.unit,
    required this.value,
  });

  factory AltitudeDatumResponse.fromMap(Map<String, dynamic> map) {
    return AltitudeDatumResponse(
      referenceDatum: map['referenceDatum'] as int,
      unit: map['unit'] as int,
      value: map['value'] as int,
    );
  }
}

class FrequencyResponse {
  final String? id;
  final String value;
  final int unit;
  final int? type;
  final String? name;
  final bool? primary;
  final bool? publicUse;
  final String? remarks;

  const FrequencyResponse({
    required this.id,
    required this.value,
    required this.unit,
    required this.type,
    required this.name,
    required this.primary,
    required this.publicUse,
    required this.remarks,
  });

  factory FrequencyResponse.fromMap(Map<String, dynamic> map) {
    return FrequencyResponse(
      id: map['_id'] as String?,
      value: map['value'] as String,
      unit: map['unit'] as int,
      type: map['type'] as int?,
      name: map['name'] as String?,
      primary: map['primary'] as bool?,
      publicUse: map['publicUse'] as bool?,
      remarks: map['remarks'] as String?,
    );
  }
}

class PolygonGeometryResponse {
  final String type;
  final List<List<List<double>>> coordinates;

  const PolygonGeometryResponse({
    required this.type,
    required this.coordinates,
  });

  factory PolygonGeometryResponse.fromMap(Map<String, dynamic> map) {
    List coordinates = map['coordinates'];
    String type = map['type'] as String;
    if (type.toLowerCase() != 'polygon') {
      return PolygonGeometryResponse(
        type: type,
        coordinates: [],
      );
    }
    return PolygonGeometryResponse(
      type: type,
      coordinates: coordinates
          .cast<List>()
          .map((e) => e
              .cast<List>()
              .map(
                (e) => e
                    .cast<num>()
                    .map(
                      (e) => e.toDouble(),
                    )
                    .toList(),
              )
              .toList())
          .toList(),
    );
  }

  bool isReverseWinding() {
    List<List<double>> pairs = coordinates[0];
    double sum = 0.0;
    for (int i = 0; i < pairs.length - 1; i++) {
      sum = sum +
          (pairs[i + 1][0] - pairs[i][0]) * (pairs[i + 1][1] + pairs[i][1]);
    }
    return sum <= 0.0;
  }

  double area() {
    List<List<double>> pairs = coordinates[0];
    double minLatitude = pairs.map((e) => e[1]).reduce(min);
    double maxLatitude = pairs.map((e) => e[1]).reduce(max);
    double minLongitude = pairs.map((e) => e[0]).reduce(min);
    double maxLongitude = pairs.map((e) => e[0]).reduce(max);
    // TODO: Actually. this is wrong. We should project to 3D space
    // and compute the area there, to avoid crossover problems
    // at the 180 degree meridian.
    return (maxLatitude - minLatitude) * (maxLongitude - minLongitude);
  }

  Coordinate centre() {
    // TODO: Compute the integral here, for a better
    // centre.
    // TODO: Project into 3D space, and compute the
    // centre from that.
    List<List<double>> pairs = coordinates[0];
    double minLatitude = pairs.map((e) => e[1]).reduce(min);
    double maxLatitude = pairs.map((e) => e[1]).reduce(max);
    double minLongitude = pairs.map((e) => e[0]).reduce(min);
    double maxLongitude = pairs.map((e) => e[0]).reduce(max);
    return Coordinate.gps(
      latitude: (maxLatitude + minLatitude) / 2,
      longitude: (maxLongitude + minLongitude) / 2,
    );
  }
}

class PointGeometryResponse {
  final String type;
  final List<double> coordinates;

  const PointGeometryResponse({
    required this.type,
    required this.coordinates,
  });

  factory PointGeometryResponse.fromMap(Map<String, dynamic> map) {
    List coordinates = map['coordinates'];
    String type = map['type'] as String;
    if (type.toLowerCase() != 'point') {
      return PointGeometryResponse(
        type: type,
        coordinates: [],
      );
    }
    return PointGeometryResponse(
      type: type,
      coordinates: coordinates
          .cast<num>()
          .map(
            (e) => e.toDouble(),
          )
          .toList(),
    );
  }
}

class AirspaceItemResponse {
  final String id;
  final PolygonGeometryResponse geometry;
  final int icaoClass;
  final AltitudeDatumResponse lowerLimit;
  final AltitudeDatumResponse upperLimit;
  final String name;
  final int type;
  final List<FrequencyResponse> frequencies;

  const AirspaceItemResponse({
    required this.id,
    required this.geometry,
    required this.icaoClass,
    required this.lowerLimit,
    required this.upperLimit,
    required this.name,
    required this.type,
    required this.frequencies,
  });

  factory AirspaceItemResponse.fromMap(Map<String, dynamic> map) {
    return AirspaceItemResponse(
      id: map['_id'] as String,
      geometry: PolygonGeometryResponse.fromMap(map['geometry']),
      icaoClass: map['icaoClass'] as int,
      lowerLimit: AltitudeDatumResponse.fromMap(map['lowerLimit']),
      upperLimit: AltitudeDatumResponse.fromMap(map['upperLimit']),
      name: map['name'] as String,
      type: map['type'] as int,
      frequencies: [
        for (final item in map['frequencies'] ?? [])
          FrequencyResponse.fromMap(item)
      ],
    );
  }
}

AirspaceLimit parseLimit(AltitudeDatumResponse limit) {
  double feet = 0.0;
  switch (limit.unit) {
    case 0: // meters
      feet = limit.value * 3.28084;
      break;
    case 1: // feet
      feet = limit.value.toDouble();
      break;
    case 2: // nm
      feet = limit.value * 6076.12;
      break;
    case 3: // km
      feet = limit.value * 3280.84;
      break;
    case 4: // mm
      feet = limit.value * 3.28084 / 1000.0;
      break;
    case 5: // cm
      feet = limit.value * 3.28084 / 100.0;
      break;
    case 6: // flight level
      feet = limit.value * 100;
      break;
  }

  return AirspaceLimit(
    feet: feet,
    datum: LimitDatum.values[limit.referenceDatum],
  );
}

class AirspaceCacheKey {
  final int longitude;
  final int latitude;

  const AirspaceCacheKey({
    required this.longitude,
    required this.latitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirspaceCacheKey &&
          runtimeType == other.runtimeType &&
          longitude == other.longitude &&
          latitude == other.latitude;

  @override
  int get hashCode => longitude.hashCode ^ latitude.hashCode;

  String get filename => '${latitude + 90}.${longitude + 180}.tile';
}

class AirspaceWithZoom {
  final int minZoom;
  final String id;

  const AirspaceWithZoom({
    required this.minZoom,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'mz': minZoom,
      'id': id,
    };
  }

  static AirspaceWithZoom fromJson(Map<String, dynamic> json) {
    return AirspaceWithZoom(
      minZoom: json['mz'] as int,
      id: json['id'] as String,
    );
  }
}

class AirportImageResponse {
  final String id;
  final String filename;
  final String? description;

  const AirportImageResponse({
    required this.id,
    required this.filename,
    required this.description,
  });

  factory AirportImageResponse.fromMap(Map<String, dynamic> map) {
    return AirportImageResponse(
      id: map['_id'] as String,
      filename: map['filename'] as String,
      description: map['description'] as String?,
    );
  }
}

class LengthResponse {
  final int value;
  final int unit;

  const LengthResponse({
    required this.value,
    required this.unit,
  });

  factory LengthResponse.fromMap(Map<String, dynamic> map) {
    return LengthResponse(
      value: map['value'] as int,
      unit: map['unit'] as int,
    );
  }

  int toMetres() {
    return value;
  }
}

class RunwayDimensionResponse {
  final LengthResponse length;
  final LengthResponse width;

  const RunwayDimensionResponse({
    required this.length,
    required this.width,
  });

  factory RunwayDimensionResponse.fromMap(Map<String, dynamic> map) {
    return RunwayDimensionResponse(
      length: LengthResponse.fromMap(map['length']),
      width: LengthResponse.fromMap(map['width']),
    );
  }
}

class RunwayResponse {
  final String id;
  final String designator;
  final int trueHeading;
  final bool alignedTrueNorth;
  final int operations;
  final bool mainRunway;
  final int turnDirection;
  final bool landingOnly;
  final bool takeOffOnly;
  final RunwayDimensionResponse dimension;
  final bool pilotCtrlLighting;

  const RunwayResponse({
    required this.id,
    required this.designator,
    required this.trueHeading,
    required this.alignedTrueNorth,
    required this.operations,
    required this.mainRunway,
    required this.turnDirection,
    required this.landingOnly,
    required this.takeOffOnly,
    required this.dimension,
    required this.pilotCtrlLighting,
  });

  factory RunwayResponse.fromMap(Map<String, dynamic> map) {
    return RunwayResponse(
      id: map['_id'] as String,
      designator: map['designator'] as String,
      trueHeading: map['trueHeading'] as int,
      alignedTrueNorth: map['alignedTrueNorth'] as bool,
      operations: map['operations'] as int,
      mainRunway: map['mainRunway'] as bool,
      turnDirection: map['turnDirection'] as int,
      landingOnly: map['landingOnly'] as bool,
      takeOffOnly: map['takeOffOnly'] as bool,
      dimension: RunwayDimensionResponse.fromMap(map['dimension']),
      pilotCtrlLighting: map['pilotCtrlLighting'] as bool,
    );
  }
}

class AirportItemResponse {
  final String id;
  final String name;
  final String? icaoCode;
  final String? iataCode;
  final String? altIdentifier;
  final String country;
  final PointGeometryResponse geometry;
  final AltitudeDatumResponse elevation;
  final int type; // 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
  final double magneticDeclination;
  final String? contact;
  final String? remarks;
  final bool ppr;
  final bool private;
  final bool skydiveActivity;
  final List<AirportImageResponse> images;
  final List<FrequencyResponse> frequencies;
  final List<RunwayResponse> runways;

  const AirportItemResponse({
    required this.id,
    required this.name,
    required this.icaoCode,
    required this.iataCode,
    required this.altIdentifier,
    required this.country,
    required this.geometry,
    required this.elevation,
    required this.type,
    required this.magneticDeclination,
    required this.contact,
    required this.remarks,
    required this.ppr,
    required this.private,
    required this.skydiveActivity,
    required this.images,
    required this.frequencies,
    required this.runways,
  });

  factory AirportItemResponse.fromMap(Map<String, dynamic> map) {
    return AirportItemResponse(
      id: map['_id'] as String,
      name: map['name'] as String,
      icaoCode: map['icaoCode'] as String?,
      iataCode: map['iataCode'] as String?,
      altIdentifier: map['altIdentifier'] as String?,
      country: map['country'] as String,
      geometry: PointGeometryResponse.fromMap(map['geometry']),
      elevation: AltitudeDatumResponse.fromMap(map['elevation']),
      type: map['type'] as int,
      magneticDeclination: (map['magneticDeclination'] as num).toDouble(),
      contact: map['contact'] as String?,
      remarks: map['remarks'] as String?,
      ppr: map['ppr'] as bool,
      private: map['private'] as bool,
      skydiveActivity: map['skydiveActivity'] as bool,
      images: [
        for (final item in map['images'] ?? [])
          AirportImageResponse.fromMap(item)
      ],
      frequencies: [
        for (final item in map['frequencies'] ?? [])
          FrequencyResponse.fromMap(item)
      ],
      runways: [
        for (final item in map['runways'] ?? []) RunwayResponse.fromMap(item)
      ],
    );
  }
}

class NavAidItemResponse {
  final String id;
  final int type;
  final String identifier;
  final String country;
  final double magneticDeclination;
  final PointGeometryResponse geometry;
  final AltitudeDatumResponse elevation;
  final bool alignedTrueNorth;
  final String? channel;
  final FrequencyResponse? frequency;
  final LengthResponse? range; // Always nautical miles
  final String? remarks;

  const NavAidItemResponse({
    required this.id,
    required this.type,
    required this.identifier,
    required this.country,
    required this.geometry,
    required this.elevation,
    required this.alignedTrueNorth,
    required this.channel,
    required this.frequency,
    required this.range,
    required this.remarks,
    required this.magneticDeclination,
  });

  factory NavAidItemResponse.fromMap(Map<String, dynamic> map) {
    return NavAidItemResponse(
      id: map['_id'] as String,
      type: map['type'] as int,
      identifier: map['identifier'] as String,
      country: map['country'] as String,
      geometry: PointGeometryResponse.fromMap(map['geometry']),
      elevation: AltitudeDatumResponse.fromMap(map['elevation']),
      alignedTrueNorth: map['alignedTrueNorth'] as bool,
      channel: map['channel'] as String?,
      frequency: map['frequency'] == null
          ? null
          : FrequencyResponse.fromMap(map['frequency']),
      range: map['range'] == null ? null : LengthResponse.fromMap(map['range']),
      remarks: map['remarks'] as String?,
      magneticDeclination: (map['magneticDeclination'] as double?) ?? 0.0,
    );
  }
}

class ReportingPointItemResponse {
  final String id;
  final String name;
  final bool compulsory;
  final String country;
  final PointGeometryResponse geometry;
  final AltitudeDatumResponse elevation;
  final List<String> airports;
  final String? remarks;

  const ReportingPointItemResponse({
    required this.id,
    required this.name,
    required this.compulsory,
    required this.country,
    required this.geometry,
    required this.elevation,
    required this.airports,
    required this.remarks,
  });

  factory ReportingPointItemResponse.fromMap(Map<String, dynamic> map) {
    return ReportingPointItemResponse(
      id: map['_id'] as String,
      name: map['name'] as String,
      compulsory: map['compulsory'] as bool,
      country: map['country'] as String,
      geometry: PointGeometryResponse.fromMap(map['geometry']),
      elevation: AltitudeDatumResponse.fromMap(map['elevation']),
      airports: [for (final item in map['airports']) item as String],
      remarks: map['remarks'] as String?,
    );
  }
}

class OpenAIPResponse {
  final List<AirspaceItemResponse> airspaces;
  final List<AirportItemResponse> airports;
  final List<NavAidItemResponse> navaids;
  final List<ReportingPointItemResponse> reportingPoints;

  const OpenAIPResponse({
    required this.airspaces,
    required this.airports,
    required this.navaids,
    required this.reportingPoints,
  });
  factory OpenAIPResponse.fromMap(Map<String, dynamic> map) {
    return OpenAIPResponse(
      airspaces: [
        for (final item in map['airspace'])
          AirspaceItemResponse.fromMap(item as Map<String, dynamic>)
      ],
      airports: [
        for (final item in map['airport'])
          AirportItemResponse.fromMap(item as Map<String, dynamic>)
      ],
      navaids: [
        for (final item in map['navaid'])
          NavAidItemResponse.fromMap(item as Map<String, dynamic>)
      ],
      reportingPoints: [
        for (final item in map['reporting-point'])
          ReportingPointItemResponse.fromMap(item as Map<String, dynamic>)
      ],
    );
  }
}

class OpenAIPRecords {
  final bool success;
  final List<Airspace> airspaces;
  final List<Airport> airports;
  final List<NavAid> navaids;
  final List<ReportingPoint> reportingPoints;

  const OpenAIPRecords({
    required this.success,
    required this.airspaces,
    required this.airports,
    required this.navaids,
    required this.reportingPoints,
  });
}

class JobRequest {
  final AirspaceCacheKey key;
  final int longitude;
  final int latitude;

  const JobRequest({
    required this.key,
    required this.longitude,
    required this.latitude,
  });
}

class AirspaceRequest extends JobRequest {
  const AirspaceRequest({
    required AirspaceCacheKey key,
    required int longitude,
    required int latitude,
  }) : super(
          key: key,
          longitude: longitude,
          latitude: latitude,
        );
}

class AirportRequest extends JobRequest {
  const AirportRequest({
    required AirspaceCacheKey key,
    required int longitude,
    required int latitude,
  }) : super(
          key: key,
          longitude: longitude,
          latitude: latitude,
        );
}

class ReportingPointRequest extends JobRequest {
  const ReportingPointRequest({
    required AirspaceCacheKey key,
    required int longitude,
    required int latitude,
  }) : super(
          key: key,
          longitude: longitude,
          latitude: latitude,
        );
}

class NavAidRequest extends JobRequest {
  const NavAidRequest({
    required AirspaceCacheKey key,
    required int longitude,
    required int latitude,
  }) : super(
          key: key,
          longitude: longitude,
          latitude: latitude,
        );
}

class AirspaceCache {
  static int queueSize = 0;
  static bool running = false;
  static Map<AirspaceCacheKey, List<AirspaceWithZoom>> airspaceTileCache = {};
  static Map<AirspaceCacheKey, List<Airport>> airportTileCache = {};
  static Map<AirspaceCacheKey, List<NavAid>> navAidTileCache = {};
  static Map<AirspaceCacheKey, List<ReportingPoint>> reportingPointTileCache =
      {};
  static Map<String, Airspace> airspaceCache = {};
  static StreamController<JobRequest> queueController = StreamController();

  static void checkRunning() {
    if (!running) {
      processLoop();
      running = true;
    }
  }

  static Future<void> getOpenAIPRecords(JobRequest job) async {
    OpenAIPRecords records = await getOpenAIPViaHttp(
      longitude: job.longitude,
      latitude: job.latitude,
    );
    if (records.success) {
      await saveAirspaces(key: job.key, airspaces: records.airspaces);
      await saveAirports(key: job.key, airports: records.airports);
      await saveNavAids(key: job.key, navAids: records.navaids);
      await saveReportingPoints(
          key: job.key, reportingPoints: records.reportingPoints);
    }
  }

  static Future<void> processAirspaceJob(AirspaceRequest job) async {
    List<AirspaceWithZoom>? prev = airspaceTileCache[job.key];
    if (prev != null) {
      if (prev.isNotEmpty) {
        // A previous job took care of this
        return;
      }
    }
    if (await loadAirspaces(key: job.key)) {
      // We managed to load the data
      return;
    }
    await getOpenAIPRecords(job);
  }

  static Future<void> processAirportJob(AirportRequest job) async {
    List<Airport>? prev = airportTileCache[job.key];
    if (prev != null) {
      if (prev.isNotEmpty) {
        // A previous job took care of this
        return;
      }
    }
    if (await loadAirports(key: job.key)) {
      // We managed to load the data
      return;
    }
    await getOpenAIPRecords(job);
  }

  static String encodeCoord({
    required int coord,
    required String neg,
    required String pos,
  }) {
    String base = (coord < 0) ? (-coord).toString() : coord.toString();
    while (base.length < 3) {
      base = '0$base';
    }
    return (coord < 0) ? '$neg$base' : '$pos$base';
  }

  static Future<Map<String, dynamic>?> getOpenAIP({
    required HttpClient client,
    required int longitude,
    required int latitude,
  }) async {
    String latitudeEncode = encodeCoord(coord: latitude, neg: 'S', pos: 'N');
    String longitudeEncode = encodeCoord(coord: longitude, neg: 'W', pos: 'E');
    Uri uri = Uri(
      scheme: 'https',
      host: 'openaip.ahardy.za.net',
      pathSegments: [latitudeEncode, '$longitudeEncode.json'],
    );
    if (kDebugMode) {
      print(uri);
    }
    HttpClientRequest request;
    try {
      request = await client.getUrl(uri);
    } catch (e) {
      return null;
    }
    request.followRedirects = true;
    request.headers.set('Accept', 'application/json');
    // Then close to send it
    try {
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        List<List<int>> chunks = await response.toList();
        List<int> bytes = [];
        for (List<int> chunk in chunks) {
          bytes.addAll(chunk);
        }
        Map<String, dynamic> payload = jsonDecode(String.fromCharCodes(bytes));
        return payload;
      } else {
        await response.drain();
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<bool> loadAirports({required AirspaceCacheKey key}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/airports/tiles');
    File tileEntryFile = File('${tileDir.path}/${key.filename}');
    List<Airport> airports = [];

    if (await tileEntryFile.exists()) {
      String stringContents = await tileEntryFile.readAsString();
      List<dynamic> contents = jsonDecode(stringContents);
      airports = contents
          .map((e) => Airport.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return false;
    }

    airportTileCache[key] = airports;
    return true;
  }

  static Future<void> saveAirports({
    required AirspaceCacheKey key,
    required List<Airport> airports,
  }) async {
    // TODO:
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/airports/tiles');
    File tileEntryFile = File('${tileDir.path}/${key.filename}');
    List<Map<String, dynamic>> contents =
        airports.map((e) => e.toJson()).toList();
    await tileDir.create(recursive: true);
    await tileEntryFile.writeAsString(jsonEncode(contents));
    airportTileCache[key] = airports;
  }

  static Future<void> processNavAidJob(NavAidRequest job) async {
    List<NavAid>? prev = navAidTileCache[job.key];
    if (prev != null) {
      if (prev.isNotEmpty) {
        // A previous job took care of this
        return;
      }
    }
    if (await loadNavAids(key: job.key)) {
      // We managed to load the data
      return;
    }
    await getOpenAIPRecords(job);
  }

  static Future<bool> loadNavAids({required AirspaceCacheKey key}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/navaids/tiles');
    File tileEntryFile = File('${tileDir.path}/${key.filename}');
    List<NavAid> navAids = [];

    if (await tileEntryFile.exists()) {
      String stringContents = await tileEntryFile.readAsString();
      List<dynamic> contents = jsonDecode(stringContents);
      navAids = contents
          .map((e) => NavAid.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return false;
    }

    navAidTileCache[key] = navAids;
    return true;
  }

  static Future<void> saveNavAids({
    required AirspaceCacheKey key,
    required List<NavAid> navAids,
  }) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/navaids/tiles');
    File tileEntryFile = File('${tileDir.path}/${key.filename}');
    List<Map<String, dynamic>> contents =
        navAids.map((e) => e.toJson()).toList();
    await tileDir.create(recursive: true);
    await tileEntryFile.writeAsString(jsonEncode(contents));
    navAidTileCache[key] = navAids;
  }

  static Future<void> processReportingPointJob(
      ReportingPointRequest job) async {
    List<ReportingPoint>? prev = reportingPointTileCache[job.key];
    if (prev != null) {
      if (prev.isNotEmpty) {
        // A previous job took care of this
        return;
      }
    }
    if (await loadReportingPoints(key: job.key)) {
      // We managed to load the data
      return;
    }
    await getOpenAIPRecords(job);
  }

  static Future<bool> loadReportingPoints(
      {required AirspaceCacheKey key}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/reporting-points/tiles');
    File tileEntryFile = File('${tileDir.path}/${key.filename}');
    List<ReportingPoint> reportingPoints = [];

    if (await tileEntryFile.exists()) {
      String stringContents = await tileEntryFile.readAsString();
      List<dynamic> contents = jsonDecode(stringContents);
      reportingPoints = contents
          .map((e) => ReportingPoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return false;
    }

    reportingPointTileCache[key] = reportingPoints;
    return true;
  }

  static Future<void> saveReportingPoints({
    required AirspaceCacheKey key,
    required List<ReportingPoint> reportingPoints,
  }) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/reporting-points/tiles');
    File tileEntryFile = File('${tileDir.path}/${key.filename}');
    List<Map<String, dynamic>> contents =
        reportingPoints.map((e) => e.toJson()).toList();
    await tileDir.create(recursive: true);
    await tileEntryFile.writeAsString(jsonEncode(contents));
    reportingPointTileCache[key] = reportingPoints;
  }

  static Future<void> processLoop() async {
    await for (JobRequest job in queueController.stream) {
      try {
        if (job is AirspaceRequest) {
          await processAirspaceJob(job);
        } else if (job is AirportRequest) {
          await processAirportJob(job);
        } else if (job is NavAidRequest) {
          await processNavAidJob(job);
        } else if (job is ReportingPointRequest) {
          await processReportingPointJob(job);
        }
      } catch (error, stackTrace) {
        Logger.logError(error.toString(), stackTrace);
        if (kDebugMode) {
          print(error.toString());
          print(stackTrace);
        }
        if (job is AirspaceRequest) {
          airspaceTileCache.remove(job.key);
        } else if (job is AirportRequest) {
          airportTileCache.remove(job.key);
        } else if (job is NavAidRequest) {
          navAidTileCache.remove(job.key);
        } else if (job is ReportingPointRequest) {
          reportingPointTileCache.remove(job.key);
        }
      } finally {
        queueSize = queueSize - 1;
      }
    }
  }

  static Future<OpenAIPRecords> getOpenAIPViaHttp({
    required int longitude,
    required int latitude,
  }) async {
    HttpClient client = HttpClient();
    List<Airspace> spaces = [];
    List<Airport> airports = [];
    List<NavAid> navAids = [];
    List<ReportingPoint> reportingPoints = [];
    bool success = false;

    Map<String, dynamic>? payload = await getOpenAIP(
      client: client,
      longitude: longitude,
      latitude: latitude,
    );

    if (payload != null) {
      success = true;
      OpenAIPResponse openaipResponse = OpenAIPResponse.fromMap(payload);
      for (final airspace in openaipResponse.airspaces) {
        if (airspace.geometry.type.toLowerCase() != 'polygon') {
          continue;
        }
        spaces.add(
          Airspace(
            id: airspace.id,
            reverseWinding: airspace.geometry.isReverseWinding(),
            area: airspace.geometry.area(),
            centre: airspace.geometry.centre(),
            name: airspace.name,
            icaoClass: IcaoClass.values[airspace.icaoClass],
            type: AirspaceType.values[airspace.type],
            lowerLimit: parseLimit(airspace.lowerLimit),
            upperLimit: parseLimit(airspace.upperLimit),
            airspace: airspace.geometry.coordinates[0]
                .map(
                  (e) => Coordinate.gps(
                    latitude: e[1].toDouble(),
                    longitude: e[0].toDouble(),
                  ),
                )
                .toList(),
            frequencies: [
              for (final f in airspace.frequencies)
                Frequency(
                  type: (f.type == null)
                      ? FrequencyType.Other
                      : FrequencyType.values[f.type!],
                  value: f.value,
                )
            ],
          ),
        );
      }
      for (final airport in openaipResponse.airports) {
        if (airport.geometry.type.toLowerCase() != 'point') {
          continue;
        }
        airports.add(
          Airport(
            id: airport.id,
            name: airport.name,
            icaoCode: airport.icaoCode,
            iataCode: airport.iataCode,
            altIdentifier: airport.altIdentifier,
            country: airport.country,
            location: Coordinate.gps(
              latitude: airport.geometry.coordinates[1],
              longitude: airport.geometry.coordinates[0],
            ),
            elevation: parseLimit(airport.elevation).feet,
            type: AirportType.values[airport.type],
            magneticDeclination: airport.magneticDeclination,
            ppr: airport.ppr,
            private: airport.private,
            skydiveActivity: airport.skydiveActivity,
            images: [
              for (final image in airport.images)
                AirportImage(
                  description: image.description ?? 'AIRPORT',
                  id: image.id,
                  airportId: airport.id,
                )
            ],
            frequencies: [
              for (final f in airport.frequencies)
                Frequency(
                  type: FrequencyType.values[f.type!],
                  value: f.value,
                )
            ],
            runways: [
              for (final runway in airport.runways)
                Runway(
                  designator: runway.designator,
                  trueHeading: runway.trueHeading,
                  mainRunway: runway.mainRunway,
                  landingOnly: runway.landingOnly,
                  takeOffOnly: runway.takeOffOnly,
                  trafficType: AirportTrafficType.values[runway.operations],
                  turnDirection: TurnDirection.values[runway.turnDirection],
                  length: runway.dimension.length.toMetres(),
                  width: runway.dimension.width.toMetres(),
                )
            ],
          ),
        );
      }
      for (final navaid in openaipResponse.navaids) {
        if (navaid.geometry.type.toLowerCase() != 'point') {
          continue;
        }
        navAids.add(
          NavAid(
            id: navaid.id,
            type: NavAidType.values[navaid.type],
            identifier: navaid.identifier,
            country: navaid.country,
            location: Coordinate.gps(
              latitude: navaid.geometry.coordinates[1],
              longitude: navaid.geometry.coordinates[0],
            ),
            elevation: parseLimit(navaid.elevation).feet,
            alignedTrueNorth: navaid.alignedTrueNorth,
            channel: navaid.channel,
            frequency: Frequency(
              type: FrequencyType.NotSpecified,
              value: navaid.frequency?.value ?? '',
            ),
            range: navaid.range?.toMetres().toDouble(),
            magneticDeclination: navaid.magneticDeclination,
          ),
        );
      }
      for (final reportingPoint in openaipResponse.reportingPoints) {
        if (reportingPoint.geometry.type.toLowerCase() != 'point') {
          continue;
        }
        reportingPoints.add(
          ReportingPoint(
            id: reportingPoint.id,
            name: reportingPoint.name,
            compulsory: reportingPoint.compulsory,
            country: reportingPoint.country,
            location: Coordinate.gps(
              latitude: reportingPoint.geometry.coordinates[1],
              longitude: reportingPoint.geometry.coordinates[0],
            ),
            elevation: parseLimit(reportingPoint.elevation).feet,
            airports: List.from(reportingPoint.airports),
          ),
        );
      }
    }
    return OpenAIPRecords(
      success: success,
      airspaces: spaces,
      airports: airports,
      navaids: navAids,
      reportingPoints: reportingPoints,
    );
  }

  static Future<void> saveAirspaces({
    required AirspaceCacheKey key,
    required List<Airspace> airspaces,
  }) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/airspaces/tiles');
    Directory airspaceDir = Directory('${appDocDir.path}/airspaces/geometry');
    File tileEntryFile = File('${tileDir.path}/${key.filename}');
    List<AirspaceWithZoom> allAirspaces =
        airspaces.map((e) => e.airspaceWithZoom()).toList();
    List<Map<String, dynamic>> contents =
        allAirspaces.map((e) => e.toJson()).toList();
    await tileDir.create(recursive: true);
    await airspaceDir.create(recursive: true);
    await tileEntryFile.writeAsString(jsonEncode(contents));
    for (Airspace airspace in airspaces) {
      File airspaceFile = File('${airspaceDir.path}/${airspace.filename}');
      Map<String, dynamic> contents = airspace.toJson();
      await airspaceFile.writeAsString(jsonEncode(contents));
      airspaceCache[airspace.id] = airspace;
    }
    airspaceTileCache[key] =
        airspaces.map((e) => e.airspaceWithZoom()).toList();
  }

  static Future<bool> loadAirspaces({
    required AirspaceCacheKey key,
  }) async {
    // TODO: Wrap in try catch block and return false
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/airspaces/tiles');
    Directory airspaceDir = Directory('${appDocDir.path}/airspaces/geometry');
    File tileEntryFile = File('${tileDir.path}/${key.filename}');
    List<Airspace> airspaces = [];
    bool missing = false;

    if (await tileEntryFile.exists()) {
      String stringContents = await tileEntryFile.readAsString();
      List<dynamic> contents = jsonDecode(stringContents);
      List<AirspaceWithZoom> allAirspaces = contents
          .map((e) => AirspaceWithZoom.fromJson(e as Map<String, dynamic>))
          .toList();
      for (AirspaceWithZoom a in allAirspaces) {
        String fileName = Airspace.getFileName(a.id);
        File airspaceFile = File('${airspaceDir.path}/$fileName');
        if (await airspaceFile.exists()) {
          String stringContents = await airspaceFile.readAsString();
          Map<String, dynamic> json = jsonDecode(stringContents);
          Airspace airspace = Airspace.fromJson(json);
          airspaceCache[airspace.id] = airspace;
          airspaces.add(airspace);
        } else {
          missing = true;
        }
      }
    } else {
      return false;
    }

    if (missing) {
      return false;
    }
    airspaceTileCache[key] =
        airspaces.map((e) => e.airspaceWithZoom()).toList();
    return true;
  }

  static Future<int> getDiskSpace() async {
    int totalDiskFootprint = 0;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/airspaces/tiles');
    Directory geometryDir = Directory('${appDocDir.path}/airspaces/geometry');
    Directory airportTileDir = Directory('${appDocDir.path}/airports/tiles');
    Directory rpTileDir = Directory('${appDocDir.path}/reporting-points/tiles');
    Directory navAidTileDir = Directory('${appDocDir.path}/navaids/tiles');
    Directory airspaceDir = Directory('${appDocDir.path}/airspaces/geometry');

    for (final Directory dir in [
      tileDir,
      airportTileDir,
      rpTileDir,
      navAidTileDir,
      airspaceDir,
      geometryDir,
    ]) {
      if (await dir.exists()) {
        List<FileSystemEntity> files = await dir.list().toList();
        for (FileSystemEntity file in files) {
          totalDiskFootprint += (await file.stat()).size;
        }
      }
    }
    return totalDiskFootprint;
  }

  static Future<void> clearCache() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory tileDir = Directory('${appDocDir.path}/airspaces/tiles');
    Directory airportTileDir = Directory('${appDocDir.path}/airports/tiles');
    Directory rpTileDir = Directory('${appDocDir.path}/reporting-points/tiles');
    Directory navAidTileDir = Directory('${appDocDir.path}/navaids/tiles');
    Directory airspaceDir = Directory('${appDocDir.path}/airspaces/geometry');

    if (await airspaceDir.exists()) {
      await airspaceDir.delete(recursive: true);
    }
    if (await tileDir.exists()) {
      await tileDir.delete(recursive: true);
    }
    if (await airportTileDir.exists()) {
      await airportTileDir.delete(recursive: true);
    }
    if (await rpTileDir.exists()) {
      await rpTileDir.delete(recursive: true);
    }
    if (await navAidTileDir.exists()) {
      await navAidTileDir.delete(recursive: true);
    }
    airspaceTileCache = {};
    airspaceCache = {};
    airportTileCache = {};
    navAidTileCache = {};
    reportingPointTileCache = {};
  }

  static void queueJob(JobRequest job) {
    // Mark that the fetch is in progress by adding an empty entry
    checkRunning();
    if (queueSize < 5) {
      queueSize = queueSize + 1;
      if (job is AirspaceRequest) {
        airspaceTileCache[job.key] = [];
      } else if (job is AirportRequest) {
        airportTileCache[job.key] = [];
      } else if (job is NavAidRequest) {
        navAidTileCache[job.key] = [];
      } else if (job is ReportingPointRequest) {
        reportingPointTileCache[job.key] = [];
      }
      queueController.add(job);
    }
  }

  static List<Airspace> getAirspaces({
    required double minLongitude,
    required double minLatitude,
    required double maxLongitude,
    required double maxLatitude,
    required int zoom,
  }) {
    Set<String> airspaceIds = {};
    int latitude;
    int longitude;
    for (latitude = minLatitude.floor();
        latitude <= maxLatitude.ceil();
        latitude++) {
      for (longitude = minLongitude.floor();
          longitude <= maxLongitude.ceil();
          longitude++) {
        AirspaceCacheKey key = AirspaceCacheKey(
          latitude: latitude,
          longitude: longitude,
        );
        List<AirspaceWithZoom>? airspaces = airspaceTileCache[key];
        if (airspaces != null) {
          airspaceIds.addAll(
            airspaces
                .where(
                  (e) => e.minZoom <= zoom,
                )
                .map(
                  (e) => e.id,
                ),
          );
        } else {
          queueJob(
            AirspaceRequest(
              key: key,
              longitude: longitude,
              latitude: latitude,
            ),
          );
        }
      }
    }

    return airspaceIds
        .map((e) => airspaceCache[e])
        .whereType<Airspace>()
        .toList();
  }

  static List<Airport> getAirports({
    required double minLongitude,
    required double minLatitude,
    required double maxLongitude,
    required double maxLatitude,
    required int zoom,
  }) {
    int latitude;
    int longitude;
    List<Airport> allAirports = [];

    if (zoom < 9) {
      return [];
    }
    for (latitude = minLatitude.floor();
        latitude <= maxLatitude.ceil();
        latitude++) {
      for (longitude = minLongitude.floor();
          longitude <= maxLongitude.ceil();
          longitude++) {
        AirspaceCacheKey key = AirspaceCacheKey(
          latitude: latitude,
          longitude: longitude,
        );
        List<Airport>? airports = airportTileCache[key];
        if (airports != null) {
          // TODO: Filter by geometry
          allAirports.addAll(airports);
        } else {
          queueJob(
            AirportRequest(
              key: key,
              longitude: longitude,
              latitude: latitude,
            ),
          );
        }
      }
    }
    return allAirports
        .where((n) =>
            (n.location.latitude >= minLatitude) &&
            (n.location.latitude <= maxLatitude) &&
            (n.location.longitude >= minLongitude) &&
            (n.location.longitude <= maxLongitude))
        .toList();
  }

  static List<ReportingPoint> getReportingPoints({
    required double minLongitude,
    required double minLatitude,
    required double maxLongitude,
    required double maxLatitude,
    required int zoom,
  }) {
    int latitude;
    int longitude;
    List<ReportingPoint> allReportingPoints = [];
    if (zoom < 9) {
      return [];
    }

    for (latitude = minLatitude.floor();
        latitude <= maxLatitude.ceil();
        latitude++) {
      for (longitude = minLongitude.floor();
          longitude <= maxLongitude.ceil();
          longitude++) {
        AirspaceCacheKey key = AirspaceCacheKey(
          latitude: latitude,
          longitude: longitude,
        );
        List<ReportingPoint>? reportingPoints = reportingPointTileCache[key];
        if (reportingPoints != null) {
          // TODO: Filter by geometry
          allReportingPoints.addAll(reportingPoints);
        } else {
          queueJob(
            ReportingPointRequest(
              key: key,
              longitude: longitude,
              latitude: latitude,
            ),
          );
        }
      }
    }
    return allReportingPoints
        .where((n) =>
            (n.location.latitude >= minLatitude) &&
            (n.location.latitude <= maxLatitude) &&
            (n.location.longitude >= minLongitude) &&
            (n.location.longitude <= maxLongitude))
        .toList();
  }

  static List<NavAid> getNavAids({
    required double minLongitude,
    required double minLatitude,
    required double maxLongitude,
    required double maxLatitude,
    required int zoom,
  }) {
    int latitude;
    int longitude;
    List<NavAid> allNavAids = [];
    if (zoom < 9) {
      return [];
    }

    for (latitude = minLatitude.floor();
        latitude <= maxLatitude.ceil();
        latitude++) {
      for (longitude = minLongitude.floor();
          longitude <= maxLongitude.ceil();
          longitude++) {
        AirspaceCacheKey key = AirspaceCacheKey(
          latitude: latitude,
          longitude: longitude,
        );
        List<NavAid>? navAids = navAidTileCache[key];
        if (navAids != null) {
          // TODO: Filter by geometry
          allNavAids.addAll(navAids);
        } else {
          queueJob(
            NavAidRequest(
              key: key,
              longitude: longitude,
              latitude: latitude,
            ),
          );
        }
      }
    }
    return allNavAids
        .where((n) =>
            (n.location.latitude >= minLatitude) &&
            (n.location.latitude <= maxLatitude) &&
            (n.location.longitude >= minLongitude) &&
            (n.location.longitude <= maxLongitude))
        .toList();
  }

  static String getAirportImageUrl(AirportImage image) {
    Uri uri = Uri(
      scheme: 'https',
      host: 'api.core.openaip.net',
      pathSegments: ['api', 'airports', image.airportId, 'images', image.id],
    );
    return uri.toString();
  }

  static Map<String, String> getImageRequestHeaders() {
    return {};
  }
}
