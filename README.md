# DU Mining Units Monitoring
 A mining units monitoring script

![Img001](https://github.com/Jericho1060/du-mining-units-monitoring/blob/main/du-mining-units-monitoring.png?raw=true)

# Guilded Server (better than Discord)

You can join me on Guilded for help or suggestions or requests by following that link : https://guilded.jericho.dev

# Installation

### required elements

- screen : 1 (you can add several il you want to display it in several places)
- programming bard : 1

### Links

Connect at least one screen to the programming board
Connect mining units to the board

You don't have to touch slots name or anything, the script will detect all elements automatically.

### installing the script

Copy the content of the file config.json then right clik on the board, chose advanced and click on "Paste Lua configuraton from clipboard"

### informations

Mining units will be displayed in the order they are linked to the board

### Options

By rightclicking on the board, advanced, edit lua parameters, you can customize these options:

- `fontSize`: the size of the text for each line on the screen
- `calibrationRedLevel`: The percent calibration below gauge will be red
- `calibrationYellowLevel`: The percent calibration below gauge will be red
- `calibrationSecondsRedLevel`: The time in seconds from last calibration above the time will be displayed in red. Default to 259200 (3 days / 72h)
- `calibrationSecondsYellowLevel`: The time in seconds from last calibration above the time will be displayed in yellow. Default to 86400 (1 day / 24h)
