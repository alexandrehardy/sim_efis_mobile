# FlightGear configuration

1. Please ensure that the network interface to listen on is selected.
2. Download [sim-efis-flightgear.xml](sim-efis-flightgear.xml) by clicking on the blue text for the file name.
3. Place the `sim-efis-flightgear.xml` protocol configuration in your FlightGear
`Protocols` directory. See below if you are unsure where that is.
4. Launch FlightGear with
`fgfs --generic=socket,out,20,{MyIP},{MyPort},udp,sim-efis-flightgear`
5. Note that the port may change if the application is stopped and restarted, or suspended and resumed.

## FlightGear Protocols directory location
 * **Mac OS X**: `Applications/FlightGear.app/Contents/Resources/data/` (right-click on `FlightGear.app` and select "Show Package Contents" to see the Contents folder)
 * **Linux**: `/usr/share/games/flightgear/`
 * **Windows**: `C:\Program Files\FlightGear 2020.3\data\` (Please put in the correct version, and note that there may be security restrictions on this directory)
 * See [https://wiki.flightgear.org/$FG_ROOT](https://wiki.flightgear.org/$FG_ROOT) for further details!
