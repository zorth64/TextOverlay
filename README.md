# TextOverlay

TextOverlay is an application for macOS written with SwiftUI that receives text by command line and shows it as an overlay on the screen, and can be used with any automation applications capable of running Shell Script, such as Shortcuts, Automator, Script Editor, Keyboard Maestro, Alfred, PopClip, and more.

## How to use

```
TextOverlay.app/Contents/MacOS/TextOverlay <TEXT> \
[-position {top|bottom|center}[,{left|right|center}]] \
[-textAlign {leading|left|center|trailing|right}] \
[-title <string>] [-titleAlign {leading|left|center|trailing|right}] \
[-icon <SF Symbol name>] [-iconPosition {left|right}] \
[-iconRenderingMode {monochrome|hierarchical|palette|multicolor}] \
[-iconColor <primary>[,<secondary>[,<tertiary>]]] \
[-marginTop <integer>] [-marginBottom <integer>] [-marginLeft <integer>] [-marginRight <integer>] \
[-overlayWidth <integer>] [-autoDismiss <bool>] [-duration <seconds>] \
[-fadeInDuration <seconds>] [-fadeOutDuration <seconds>] \
[-transition {fade|scale|fromTop|fromBottom|fromLeft|fromRight|none}] \
[-colorScheme {system|light|dark|inverted}]
```

## Params

### `<TEXT>`
The first parameter is the text of the information to be shown, which may contain one or more lines of text.

#### In-line SF Symbol:
Supports the insertion of SF Symbols icons along the text by inserting the placeholder with the following format:

`[<SF Symbol name>]`

The in-line SF Symbol icon marker is automatically replaced by the symbol whose name is defined between the bracket characters.

#### Custom Text Color:
You can set a color for a specific text snippet with the following syntax:

`<color=<Color name>;<The text to which the color will be applied>>`

Standard macOS system color names are supported, such as `red`, `yellow`, `green` and `accentColor`. It is also possible to define colors using hexadecimal color code.

For example, the text `The quick brown <color=brown;fox> jumps over the lazy dog` applies the brown color to the word “fox”.

### `-position <vertical>[,<horizontal>]` (default: `center,center`)
Defines the vertical and horizontal position of the screen where the overlay should be displayed. The values must be separated by comma. The first value indicates the vertical position (options: `top`, `bottom` or `center`), and the second value indicates the horizontal position (options: `left`, `right` or `center`).

For example, to show the overlay at the top and center of the screen, just use the `-position "top"` parameter.

### `-textAlign` (default: `center`)
Defines the text alignment. Options:

- `left`<br>
- `leading` (alias of `left`)<br>
- `center`<br>
- `right`<br>
- `trailing` (alias of `right`)

### `-title`
Defines the first line of text that is shown just above the main text. It is automatically formatted in bold. It also supports the insertion of SF Symbols along the text by inserting the marker `[<SF Symbol name>]` at the desired position.

### `-titleAlign` (default: `center`)
Allows you to set the alignment of the title independently of the alignment of the main text. The available options are the same as the `-textAlign` parameter.

### `-icon`
Allows you to set an SF Symbol icon to be shown as the main icon on the overlay. The argument is the name of the SF Symbol icon.

Example:

`-icon "heart.fill"`

### `-iconPosition` (default: `left`)
Defines the position where icon is shown on the overlay. The options are `left` or `right`.

### `-iconRenderingMode` (default: `monochrome`)
Allows you to set the rendering mode of the colors of the main icon. The options are:

- `monochrome`<br>
- `hierarchical`<br>
- `palette`<br>
- `multicolor`

### `-iconColor`
Allows you to set the colors of the main icon shown on the overlay. Up to 3 comma-separated arguments can be passed following the following syntax:

`-iconColor <primary>[,<secondary>[,<tertiary>]]`

Standard macOS system color names are supported, such as `red`, `yellow`, `green` and `accentColor`. It is also possible to define colors using hexadecimal color code.

### `-marginTop`, `-marginBottom`, `-marginLeft`, `-marginRight`
Allows you to define margins that the overlay should have at each end of the screen. The default values in pixels are:

- `-marginTop` (default: 110)<br>
- `-marginBottom` (default: 120)<br>
- `-marginLeft` (default: 50)<br>
- `-marginRight` (default: 50)

### `-maxWidth`
By default, the TextOverlay application does not add line breaks to the text that is received by parameter, and the dimensions of the overlay automatically adjust to accommodate the content. This can be a problem when the user has no control over the text that will be displayed. In this case, the `-maxWidth` parameter limits the width of the overlay and adds line breaks to the text automatically when necessary.

### `-autoDismiss <bool>` (default: `false`)
The default behavior of the overlay is to remain visible on the screen until the user clicks on it with the mouse to discard it. To discard the overlay automatically after a predefined period of time, use the `-autoDismiss true` parameter.

### `-duration <seconds>` (requirement: `-autoDismiss true`)
Allows you to set the duration of the time interval in seconds in which the overlay is displayed on the screen until it is automatically discarded. If the duration ends while the mouse pointer is over the overlay, it continues to be shown until the user moves the mouse pointer out of the overlay area. The user can click on the overlay at any time to discard it in advance.

### `-transition` (default: `fade`)
Sets the animation style with which the overlay appears on the screen. The available options are:

- `fade`<br>
- `scale`<br>
- `fromTop`<br>
- `fromBottom`<br>
- `fromLeft`<br>
- `fromRight`<br>
- `none`

### `-fadeInDuration <seconds>` (default: `1.0`)
Allows you to set the duration in seconds of the animation with which the overlay appears on the screen.

### `-fadeOutDuration <seconds>` (default: `1.0`)
Allows you to set the duration in seconds of the animation with which the overlay disappears from the screen.

### `-colorScheme` (default: `system`)
Allows you to set the appearance style of the overlay. The options are:

- `system` (Same appearance of the system)<br>
- `light`<br>
- `dark`<br>
- `inverted` (Displays light appearance when the system appearance is set to dark, or dark when the system appearance is set to light)

## Examples

- Battery Cycles:

<img src="https://raw.githubusercontent.com/zorth64/TextOverlay/master/Gifs/battery-cycles.gif" width="474" height="342"/>

```
cycles=$(ioreg -l | grep -E -o -m 1 '"Cycle Count"=\d+' | grep -E -o -m 1 "\d+")

"TextOverlay.app/Contents/MacOS/TextOverlay" "Battery cycles:\n$cycles" \
-position "bottom" -duration "4" -fadeInDuration 0.5 -fadeOutDuration 0.5 \
-marginBottom 120 -icon "battery.100percent.circle" -iconRenderingMode "palette" \
-iconColor "primary,green" -colorScheme "inverted" > /dev/null &
```

- Disk Space:

<img src="https://raw.githubusercontent.com/zorth64/TextOverlay/master/Gifs/disk-space.gif" width="440" height="342"/>

```
TextOverlay.app/Contents/MacOS/TextOverlay "${DiskUsage}" \
-position "bottom" -marginBottom 120 -textAlign "left" \
-title "Available Disk Space" -titleAlign "center" \
-autoDismiss YES -duration "8" -fadeInDuration 0.4 -fadeOutDuration 0.5 \
-icon "internaldrive.fill" -colorScheme "inverted" > /dev/null &
```

- Power Status:

<img src="https://raw.githubusercontent.com/zorth64/TextOverlay/master/Gifs/power-status.gif" width="489" height="342"/>

```
message=""
icon=""
color=""

if [ $(ioreg -l | grep -E -o -m 1 '"ExternalConnected" = Yes' \
| grep -E -o -m 1 "Yes" | wc -l) -ge 1 ];
then
    message="Battery Charger Connected"
    icon="battery.100percent.bolt"
    color="primary,secondary,green"
else
    message="Battery Charger Disconnected"
    icon="battery.50percent"
    color="yellow"
fi

TextOverlay.app/Contents/MacOS/TextOverlay "$message" \
-position "top" -marginTop 110 -autoDismiss YES \
-duration "3.5" -transition "fromTop" -fadeInDuration 0.8 -fadeOutDuration 0.8 \
-icon "$icon" -iconRenderingMode "palette" -iconColor "$color" \
-colorScheme inverted > /dev/null &
```

- CPU Usage:

<img src="https://raw.githubusercontent.com/zorth64/TextOverlay/master/Gifs/cpu-usage.gif" width="477" height="342"/>

```
"TextOverlay.app/Contents/MacOS/TextOverlay" "$text" \
-position "center" -textAlign "left" -icon "cpu.fill" -transition "scale" \
-fadeInDuration 0.5 -fadeOutDuration 0.3 -autoDismiss YES -duration 6 > /dev/null &
```

- Weather:

<img src="https://raw.githubusercontent.com/zorth64/TextOverlay/master/Gifs/weather.gif" width="440" height="342"/>

```
TextOverlay.app/Contents/MacOS/TextOverlay "[${Weather_icon}] ${Weather_name}
[thermometer.medium] ${Weather_temperature}
↓${Weather_low} ↑${Weather_high}
[umbrella.percent.fill] ${Weather_precipitation}" \
-position bottom,center -marginBottom 120 \
-transition scale -fadeInDuration 0.5 -fadeOutDuration 0.3 \
-autoDismiss YES -duration 10 -colorScheme "inverted" > /dev/null &
```

## License
[GNU General Public License](https://github.com/zorth64/TextOverlay/blob/master/LICENSE)