# X-Plane configuration

1. Enter the host or subnet to scan for X-Plane.
2. Enter the port (using the default is recommended) that X-Plane is listening on.
3. Sim-EFIS will use this information to contact and reconfigure X-Plane to forward instrument data to Sim-EFIS.

## Manually configuring X-Plane.

If for some reason Sim-EFIS cannot reconfigure X-Plane, you can manually setup X-Plane
to send the data to Sim-EFIS by configuring the DATA OUTPUT NETWORK CONFIGURATION.

Set the IP Address and Port to the values shown on the Settings screen (the listening
address and port will be shown on the Settings screen
after viewing the logs, or switching to the main display after configuring the
simulator.

At the moment the configuration is:
* IP: {MyIP}
* Port: {MyPort}

The [X-Plane youtube video](https://www.youtube.com/watch?v=QMSxAitED8Y) provides
instruction for how to do this.

Ensure that the following items are set for output via UDP:
* Times
* Speeds
* Mach, VVI, g-load
* Trim, flap, stats & speedbrakes
* Angular moments
* Angular velocities
* Pitch, roll, & headings
* Angle of attack, sideslip, & paths
* Latitude, longitude, & altitude
* Engine RPM
* Manifold pressure
* Oil pressure
* Oil temperature
* Fuel weights
* Fuel flow
* Landing gear deployment
* Exhaust gas temperature
* Cylinder head temperature


Also request the following datarefs to be sent:
* `sim/aircraft/view/acf_tailnum`
* `sim/aircraft/view/acf_ICAO`
* `sim/aircraft/view/acf_Vso`
* `sim/aircraft/view/acf_Vs`
* `sim/aircraft/view/acf_Vfe`
* `sim/aircraft/view/acf_Vno`
* `sim/aircraft/view/acf_Vne`
* `sim/aircraft/engine/acf_max_EGT`
* `sim/aircraft/engine/acf_max_CHT`
* `sim/aircraft/engine/acf_max_OILP`
* `sim/aircraft/engine/acf_max_OILT`
* `sim/aircraft/limits/green_lo_MP`
* `sim/aircraft/limits/green_hi_MP`
* `sim/aircraft/limits/yellow_lo_MP`
* `sim/aircraft/limits/yellow_hi_MP`
* `sim/aircraft/limits/red_lo_MP`
* `sim/aircraft/limits/red_hi_MP`
* `sim/aircraft/limits/green_lo_EGT`
* `sim/aircraft/limits/green_hi_EGT`
* `sim/aircraft/limits/yellow_lo_EGT`
* `sim/aircraft/limits/yellow_hi_EGT`
* `sim/aircraft/limits/red_lo_EGT`
* `sim/aircraft/limits/red_hi_EGT`
* `sim/aircraft/limits/green_lo_CHT`
* `sim/aircraft/limits/green_hi_CHT`
* `sim/aircraft/limits/yellow_lo_CHT`
* `sim/aircraft/limits/yellow_hi_CHT`
* `sim/aircraft/limits/red_lo_CHT`
* `sim/aircraft/limits/red_hi_CHT`
* `sim/aircraft/limits/green_lo_oilP`
* `sim/aircraft/limits/green_hi_oilP`
* `sim/aircraft/limits/yellow_lo_oilP`
* `sim/aircraft/limits/yellow_hi_oilP`
* `sim/aircraft/limits/red_lo_oilP`
* `sim/aircraft/limits/red_hi_oilP`
* `sim/aircraft/limits/green_lo_oilT`
* `sim/aircraft/limits/green_hi_oilT`
* `sim/aircraft/limits/yellow_lo_oilT`
* `sim/aircraft/limits/yellow_hi_oilT`
* `sim/aircraft/limits/red_lo_oilT`
* `sim/aircraft/limits/red_hi_oilT`
