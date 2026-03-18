# Microsoft Flight Simulator 2020 configuration

1. Sim-EFIS requires third party software to integrate with MSFS2020.
2. Download [Instrument Data Link](https://github.com/alexandrehardy/instrument-data-link/releases/download/v1.6.2-gps/instrument-data-link-v1.6.2-gps-windows-x64.zip) **version 1.6.2** from the
[github releases](https://github.com/alexandrehardy/instrument-data-link/releases) page for the project.
3. It is important to install exactly **version 1.6.2** of instrument-data-link, because the network protocols differ from one version to the next, and Sim-EFIS is thus only able to communicate with version 1.6.2.
3. Unzip the distribution package for instrument-data-link.
4. Before launching MSFS2020, first run `instrument-data-link.exe`. This will allow Sim-EFIS to get information from MSFS2020, via instrument-data-link.
5. In the network section of Sim-EFIS, enter the IP address of your machine running MSFS2020 (or provide a subnet to scan), and enter the port that instrument-data-link is listening on. By default, instrument-data-link listens on port 52020.
