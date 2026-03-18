# Introduction

Sim-EFIS is an electronic flight information system for flight simulator
computer games. The main functions offered (depending on whether the
simulator supports it) are:
 * An analog instrument panel covering traditional instruments.
 * An analog engine panel.
 * A "Primary Flight Display" (PFD) which acts like a "Head Up Display" (HUD).
 * Settings for aircraft so that instruments have the correct limits for
    the current aircraft.
 * An electronic logbook which can be used to track flights (this is not linked
    with any flight simulator logbook).
 * A checklist screen, for displaying checklists during flight.
 * A moving map display (if the simulator provides location information).

Tap the @(icon:zoom_out_map) icon to open an image.

The image can then be scaled
and panned and to view details of the image.

Note that all screens work whether the screen is tilted horizontally
or vertically. If you have difficulty with a screen in one orientation,
try rotate the screen to access the function.

# Screen Layout

The main screen has a number of functions on it:

![Screen layout](resource:assets/help/images/main.png?size=564x300)

The basic analog instrument layout is described later. The icons
on the screen are:
* @(icon:settings): Settings screen

    Tapping this icon takes you to the
    settings screen,
    where the simulator to connect to can be
    configured, and details on how to setup the simulator can be found.
* @(icon:question): Help screen

    Tapping on this icon takes
    you to this help screen.
* @(icon:view_sidebar): Instrument selection

    The main EFIS screen can be split
    into two separate panels. There is a left and right panel when in
    horizontal mode, and a top and bottom panel when in vertical mode.
    This icon activates the panel selection screen to allow the desired
    panel to be selected.
* @(icon:stop:fff44336): Not connected

    This icon is displayed when Sim-EFIS is not receiving any data
    from the flight simulator. You may have to reconfigure Sim-EFIS
    or the flight simulator to establish a connection.
* @(icon:play_arrow:ff4caf50): Connected to flightsim

    This icon is displayed when Sim-EFIS is receiving data from
    the flight simulator, and displaying that data. If space is available
    then the time as reported by the flight simulator will also be
    displayed.

# Selecting A Screen
Tap @(icon:view_sidebar) to select a panel.

The panel selection screen then displays:

![Selecting a panel](resource:assets/help/images/panels.png?size=564x300)

There are several options available for the left or right panel (
top or bottom panel in vertical mode):
* **PFD**: This selects the Primary Flight Display, which is similar to a Head Up Display (HUD).
* **MAP**: A moving map display with topographical features (from [www.opentopomap.org](https://www.opentopomap.org)).
* **NONE**: Leave this panel blank, the other panel will then expand to use the space this panel would normally use.
* **AIRPORTS**: List of airports near the aircraft (from [www.openaip.net](https://www.openaip.net)).
* **AIRSPACE**: Horizontal view of airspaces, or list of airspaces near the aircraft (from [www.openaip.net](https://www.openaip.net)).
* **ENGINE**: An analog display that shows the RPM, manifold pressure, and temperatures for the engines of the aircraft.
* **LOGBOOK**: A flight simulator logbook, for keeping track of your virtual flights.
* **PARAMS**: Aircraft parameters (not always available from the simulator) that affect the display of instruments.
    These include the Vs and Vne speeds, number of engines, etc.
* **CHKLIST**: View, edit and create checklists.
* **6 PACK**: The airspeed indicator, attitude indicator, altimeter, slip/turn indicator, direction indicator, vertical speed indicator.
* **9 PACK**: Everything in the 6 PACK, as well as the landing gear and flap status, and RPM for the first engine.
* **12 PACK**: Everything in the 9 PACK, as well as manifold pressure and oil temperature and pressure for the first engine.

# Analog Instrument Screens

All analog instrument screens are passive displays. The full set of
analog instruments (excluding additional engine instruments) is rendered as follows:

![Analog instruments](resource:assets/help/images/all-instruments.png?size=564x300)

Each instrument can be tapped to give a zoomed view of the instrument:

![Airspeed indicator](resource:assets/help/images/airspeed.png?size=564x300)

Tapping the instrument again will return the view back to normal.

# The Primary Flight Display
The Primary Flight Display is useful for displaying a lot of information
in a compact space. The display will be configured in horizontal mode
or vertical mode based on the amount of space available for the panel.

In horizontal mode, the screen layout is as follows:
 
![Horizontal PFD](resource:assets/help/images/horizontal-pfd.png?size=564x300)

The display consists of:
* The **artificial horizon**: The line separating the blue area and brown area is the artificial horizon.
* The **heading tape** and **heading caret**: The heading tape scrolls past, showing the direction of turn,
    the actual magnetic heading is at the position just above the heading caret.
* The **airspeed tape**: The airspeed tape indicates the current airspeed in a black box over the tape.
    In addition to the airspeed, the colored intervals from the analog airspeed indicator are
    also displayed to indicate Vs, Vne, Vno, Vfe etc.
* The **heading bug**: Sim-EFIS has its own heading bug, which is **not** connected to the simulator
    heading bug. The current direction of the heading bug is indicated above the airspeed tape. The
    heading tape also indicates the heading bug as a thick blue line.
* The **altitude tape**: The altitude tape indicates the current altitude in a black box over the tape.
* The **altitude bug**: The altitude bug is **not** connected to the simulator, and is indicated in
    numerical form at the top of the altitude tape, as well as in the form of a blue tab which slides
    with the altitude tape.
* The **flap indicator**: The current flap setting is shown as a white line on the outside edges of
    both the airspeed tape as well as the altitude tape. When the flaps are fully retracted, then 
    the white line is no longer visible.
* The **pitch ladder**: The pitch ladder indicates the angle of descent or climb, and is in the
    middle of the display.
* The **gear indicator**: Three dots are displayed for the gear. If the dot is gray, then the
    gear is in transition. If the dot is green, then the gear is down and locked. A red dot
    means the gear is fully retracted. The gear indicator disappears when all three gear are
    indicated as retracted. There is an indicator for the nose gear, left gear and right gear.
* The **heading bug knob**: The heading bug can be set by tapping the heading bug knob. A single tap
    will produce a single increment of the heading. For faster changes, press and hold the
    heading knob. The direction (increase or decrease) is determined by the knob direction
    indicator.
* The **altitude bug know**: The altitude bug can be set by tapping the altitude bug knob for fine
    changes (in 100ft increments). Press and hold the knob for faster changes.
* The **knob turn direction**: Tap to change the direction of turn of the heading and altitude
    bug knobs. A green indicator indicates that the bug value will increase, and red indicates
    that the bug value will decrease. If the knob is gray, with the text "FIX", then the pressing
    the knob will set the bug to the current heading or altitude.

The vertical mode is similar:

![Vertical PFD](resource:assets/help/images/vertical-pfd.png?size=300x564)

The additional features for vertical mode are:
* The **roll bar**: The roll bar replaces the heading tape in vertical mode, and indicates the
    bank angle of the aircraft with standard markers.
* The **direction indicator**: A direction indicator is added with the **heading** displayed in
    a box above the direction indicator.
* The **heading bug**: The heading bug in vertical mode is displayed on the direction indicator,
    and the heading bug numerical value is displayed in blue to the lower right of
    the direction indicator. Note once again that this bug is not connected to the simulator.
    The bug is independent of the simulator bug.
* The **flap indicator**: The flap indicator is now to the left of the direction indicator
    and indicates the flap position, with additional marks to help determine how far the
    flaps are extended. A caret is used to indicate the flap position.
* The **elevator trim**: The elevator trim position is indicated to the right of the 
    direction indicator.
* The **rudder trim**: The rudder trim is indicated below the direction indicator.

# The Moving Map Display
The moving map display displays a topographic map from [www.opentopomap.org](https://www.opentopomap.org):

![Moving map](resource:assets/help/images/map.png?size=564x300)

The map will only display meaningful information for flight simulators that Sim-EFIS
can obtain the GPS information of the aircraft from.

The aircraft is located where the red aircraft icon is displayed. The scale of
the map is also displayed in red at the bottom left of the map, along with the
current altitude and airspeed.

The map can be panned (moved) by touching the screen and dragging
the map in the direction you would like to move it.

There are five icons available for interacting with the map:
* @(icon:settings): Set what is rendered on the map
* @(icon:aircraft): Recenter the map on your aircraft
* @(icon:remove_circle): Zoom out
* @(icon:add_circle): Zoom in
* @(icon:compass): Change heading mode

    The compass icon will track the direction of true north by default,
    and the map will be rotated so that the aircraft icon is always
    pointing up.

    If you tap on the icon, then the map will instead be rendered with true
    north up, and the compass will no longer rotate. Tapping on the compass
    icon again will reset the map rendering to the default, with the
    aircraft icon is once again pointing up.

The map settings screen will open up in the opposite panel to the map,
and when closed will restore whatever panel was covered by the map settings.

![Map settings](resource:assets/help/images/map-settings.png?size=564x300)

The map settings screen determines what extra information is rendered on the
map:
* Brightness: The map can be set to be darker or brighter to increase contrast with items rendered over the map.
* Airspace toggle: Determines whether airspaces are rendered.
* Airport toggle: Determines whether airports are rendered.
* Nav Aid toggle: Determines whether VOR beacons are rendered.
* Reporting points toggle: Determines whether VFR reporting points are rendered.
* Parachute zones: Determines whether airspaces with a PJE prefix are rendered.
* Min altitude: Only airspaces that intersect the range between the minimum altitude and maximum altitude are rendered.
* Max altitude: Only airspaces that intersect the range between the minimum altitude and maximum altitude are rendered.
* Airspace types: Determine which airspace types are rendered.
* Airspace class: Determine which airspace classes are rendered.

Note that the airfield and airspace data are obtained from [www.openaip.net](https://www.openaip.net). Any errors in
the airspace information should be corrected on [www.openaip.net](https://www.openaip.net), and the airspace cache
should be erased to allow the new airspace information to be downloaded.

# The Airport List Screen

This screen displays the airports nearest to the aircraft, or those nearest to the center of the map, sorted by distance.

![Airport list](resource:assets/help/images/airports.png?size=300x564)

Each airport has the following information displayed:
* Distance to the airport
* @(icon:location_north): An indication of where the airport is relative to the aircraft.
* @(icon:location_pin): When tapped, the airport will be centered on the map.
* @(icon:info_outline): When tapped, more detailed airport information will be shown.

The further details of the airport include:
* Elevation and GPS coordinates
* Runways
* Radio frequencies in use

![Airport detail](resource:assets/help/images/airport-detail.gif?size=300x564)

# The Airspace Information Screens

In addition to the airspace information on the map, additional airspace
information can be displayed when selecting the airspace panel.

![Airspace panel](resource:assets/help/images/airspace-select.png?size=300x564)

* Airspace list: This displays a list of airspaces, ordered by the distance from the center of the airspace to the aircraft.
* Section display: This displays the aircraft from the side, with the upcoming airspaces.

![Airspace list](resource:assets/help/images/airspace-list.png?size=300x564)

The airspace list is similar to the airport list screen, the following information
from [www.openaip.net](https://www.openaip.net) is displayed:
* The name of the airspace.
* The lower and upper limit of the airspace.
* The distance to the center of the airspace.
* @(icon:location_pin): When tapped, the center of the airspace will be centered on the map.

The section view is useful for seeing what airspace the aircraft is in, and which airspaces will be entered next.
![Airspace panel](resource:assets/help/images/airspace-side.png?size=564x300)

The following information is displayed:
* The airspace the aircraft is in is displayed in the top white bar.
* The airspaces are shown as volumes you can fly through, color coded based on the airspace type.
* The distance to the boundary of the airspace, at the current heading is shown.
* The aircraft is shown as a red aircraft, and shows the pitch angle of the aircraft.
* @(icon:remove_circle): Tapping this icon decreases the zoom level, allowing you to see further.
* @(icon:add_circle): Tapping this icon increases the zoom level, reducing the visible distance.

Note that the vertical limits remain the same, irrespective of the zoom level.

In addition to the above, two gray lines are drawn:
* One vertical gray line is draw through the center of the aircraft, which shows the position from which the
  current airspace is determined.
* A projected flight path is also drawn as a gray line. Note that the projected path of the aircraft may not
  match the pitch of the aircraft since the horizontal and vertical extents are not equal.

# The Aircraft Configuration Screen
The aircraft configuration can be modified by selecting the **PARAMS** panel.
The panel is best viewed in portrait mode.

![Aircraft configuration](resource:assets/help/images/aircraft-config.png?size=300x564)

The aircraft configuration screen is used to setup the instruments
so that they indicate various speeds and values correctly for the aircraft.
The name of the aircraft identified by the simulator is displayed at the
top of the page, and the settings currently loaded are displayed under that.

The number of engines, as well as various speeds that may be marked on the
PFD and airspeed indicator, and various engine parameters can be set.
These parameters determine how the respective instruments are rendered.

Once you have set the appropriate configuration for the aircraft, you
can **SAVE** the parameters. If the parameters are not saved, then the parameters
will only apply to the current session.

If you do **SAVE** the parameters, then they will be saved under
the aircraft name specified. Whenever the simulator reports that this
aircraft is being flown, the parameters will automatically be loaded
and applied to the instruments.

In the event that the simulator does not accurately provide the aircraft
type being flown, or does not report it at all, you may use the **LOAD**
button to load previously saved parameters for the aircraft.

These parameters may also be exported from the **SETTINGS** screen for
backup purposes, or to transfer the configuration to another device.

Each parameter can be adjusted using the two knobs next to it:
* @(icon:add_circle):
    Tapping this icon increments the value by one. Press and hold the
    icon to increment the value quickly (for making larger changes).
* @(icon:remove_circle):
    Tapping this icon decrement the value by one. Press and hold the
    icon to decrement the value quickly (for making larger changes).

# The Logbook
The logbook panel can be used to record simulator flights. The initial
screen shows the list of existing logs:

![Logbook panel](resource:assets/help/images/logbook.png?size=564x300)

When ready to begin a flight, press the **OPEN** button. A new entry will
be created in the logbook. A landing is counted when the aircraft is
flying at an airspeed below the stall speed, and there is no significant
vertical speed indicated (this generally indicates that the aircraft has touched the ground).

The open flight is highlighted in green as show here:

![Opening the flight](resource:assets/help/images/logbook-open.png?size=564x300)

When the flight has been completed, tap the **CLOSE** button. At this
point final details about the duration of the flight are recorded.

If there are any errors in the logbook entry, then tap on the 
@(icon:edit) to correct the entry. Once this icon is tapped a screen
similar to the following is displayed:

![Editing the logbook](resource:assets/help/images/logbook-edit.png?size=564x300)

Note that the flight can only be edited once the flight has been closed.
Once editing is completed, simply tap the "X" in the top left corner
to close the entry and save changes.

To delete this entry tap on **DELETE**. If there are other entries in the
logbook, then the **NEXT** and **PREV** buttons can be used to navigate
between entries.

# The Checklist Screen
Sim-EFIS supports the creation of checklists to use while flying
virtual aircraft. Select the **CHECKLIST** panel to access these
checklists.

The checklist appears as below:

![Checklist panel](resource:assets/help/images/checklist.png?size=300x564)

The top row of the checklist panel allows you to:
* **SELECT** a checklist to view (in this case SLING2 is selected).
* **ADD NEW** checklist to Sim-EFIS.
* **FILTER** checklists so that only a subset of the checklists are visible in the top row.
  This is useful if there are multiple checklists for multiple aircraft, and
  you only want the relevant checklists to be visible. Other checklists can
  be made visible again using the **FILTER**.

The **FILTER** option lists all the checklists:
![Filtering checklists](resource:assets/help/images/checklist-filter.png?size=300x564)

The icons used in the filter are:

* @(icon:check:ff4caf50):
    The check mark indicates that this checklist is selected for display. If no checklists
    are selected, then all will be visible. You can toggle the check mark by tapping
    on the name of the checklist.

* @(icon:edit):
    Tap this icon to edit the checklist.

* @(icon:delete):
    Tap this icon to delete the checklist.

Tap the **FILTER** button to apply the selection.

The new checklist screen begins by entering the name of the new checklist:

![New checklist](resource:assets/help/images/new-checklist.png?size=300x564)

Tap on the @(icon:add_circle_outline) to add an additional
entry to the checklist. After tapping the icon, the following screen appears:

![Add checklist entry](resource:assets/help/images/add-checklist-entry.png?size=300x564)

There are two classes of items in the checklist:
* A heading
* A checklist item, which includes a prompt, and expected response.

If you tap on the "Make this a heading" check box then the interface will change to
allow the heading to be entered:

![Add checklist heading](resource:assets/help/images/add-checklist-heading.png?size=300x564)

Tap **SAVE** to save the entry, or tap on @(icon:arrow_back)
to discard the entry.

The items in the checklist can be edited:
![Reorder checklist](resource:assets/help/images/checklist-reorder.png?size=300x564)

Tap on the icons to modify the items in the checklist:
* @(icon:remove_circle_outline):
    This icon removes the corresponding entry from the checklist.

* @(icon:arrow_circle_down):
    This icon moves the entry down in the checklist (and the
    entry below that is moved up).

* @(icon:arrow_circle_up):
    This icon moves the entry up in the checklist (and the
    entry above that is moved down).

# Configuring For A Flightsim
Tapping on the @(icon:settings) icon opens
the settings screen.

![Settings](resource:assets/help/images/settings.png?size=300x564)

The first section of the screen selects the flight
simulator to connect to.

Tap the DETAILED CONFIGURATION button to get configuration information
for the simulator, and any configuration files or software
which may be needed to allow Sim-EFIS to communicate with the
simulator software.

Sim-EFIS connects with the simulator over the local network. In
most cases the default configuration as chosen by Sim-EFIS
should work relatively well. Sim-EFIS will choose the wireless
network for communication and attempt to find the simulator
by scanning the network. If scanning fails, you can type
in the IP address of the machine to connect to.

![Settings Network](resource:assets/help/images/settings-network.png?size=300x564)

Each network is indicated by an icon.
* @(icon:wifi): Wifi network
* @(icon:three_g_mobiledata): Mobile network
* @(icon:question_circle): A network Sim-EFIS failed to classify.
* All: If this is selected, Sim-EFIS will listen for information
from the simulator from all network interfaces on the phone. This
is not the recommended configuration.

![Settings Map](resource:assets/help/images/settings-map.png?size=300x564)

Sim-EFIS caches map data so that the map can also be rendered
when not connected to the internet. If the space used by Sim-EFIS
becomes too large, you can clear the map cache by tapping
on the CLEAR MAP CACHE button.

Below the map settings, there is a FILTER QUALITY setting. Higher
values make the graphics smoother, but use more battery power.
Lower filter quality can make the graphics more jaggy, but should
improve performance and battery usage (although the improvement
may be minor).

The aircraft configurations and checklists can also be exported via
e-mail or simply copying the text definition. These configurations
and checklists can then be imported in Sim-EFIS on another device.

![Settings Export](resource:assets/help/images/settings-export.png?size=300x564)

# Exporting And Importing Aircraft
The export aircraft parameters screen is shown after tapping on EXPORT AIRCRAFT.

![Export Aircraft](resource:assets/help/images/export-aircraft.png?size=300x564)

Select which items you wish to export, which are then marked with a check mark (@(icon:check:ff4caf50)).
Tap the item again to deselect it.

When ready, tap on EXPORT to export the parameters for these aircraft in a text format.

![Export Aircraft Files](resource:assets/help/images/export-aircraft-files.png?size=300x564)

Sim-EFIS will ask if you want to share the data as files.
* If you share as files, then the export will be shared as a file, suitable for attachment
  to an e-mail.
* If you do not share as files, then the export will be pure text that can be pasted
  into an e-email.

For import, a large text box is provided to paste the aircraft configuration
previously saved:

![Import Aircraft](resource:assets/help/images/import-aircraft.png?size=300x564)

Paste the previously saved parameters and tap IMPORT to import the associated
data. A message will be displayed to indicate if the import was successful.

# Exporting And Importing Checklists
The process for for exporting checklists is very similar to exporting
aircraft parameters:

![Export Checklist](resource:assets/help/images/export-checklist.png?size=300x564)

Select the checklists to export, and then tap on EXPORT. Sim-EFIS will ask whether
you wish to share the data as files. This question will be used to determine
how the data is shared in the same way as the aircraft configuration.

The import checklist screen also behaves similarly to the import aircraft configuration:

![Import Checklist](resource:assets/help/images/import-checklist.png?size=300x564)

Simply paste the previously exported checklist content into the checkbox, and tap IMPORT
to import the checklists.

# Viewing logs
If you have problems connecting Sim-EFIS to your simulator, then you
can tap on the LOGS button to view any information about what is happening.

![View Logs](resource:assets/help/images/logs.png?size=300x564)

This screen should also be provided for any support queries. Any
errors are logged here, as well as whether any responses have
been received from the simulator.
