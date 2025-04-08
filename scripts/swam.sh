#!/bin/bash
#++++++++++++++++
# SWAM - Screen Window Advanced Mover
#
# Moves currently focused window to the leftmost (0) or rightmost (1) monitor.
# Usage: bash swam.sh [direction]
#   - bash swam.sh 0: Move window to the leftmost monitor
#   - bash swam.sh 1: Move window to the rightmost monitor
#
# If the window is maximized it will remain maximized after being moved.
# If the window is not maximized it will retain its current size, unless
# height is too large for the destination monitor, when it will be trimmed.
#++++++++++++++++

# Check for direction parameter
if [ $# -ne 1 ] || [ "$1" != "0" -a "$1" != "1" ]; then
    echo "Usage: $0 [direction]"
    echo "  0: Move window to the leftmost monitor"
    echo "  1: Move window to the rightmost monitor"
    exit 1
fi

DIRECTION=$1

# Window title bar height (default title bar height in Gnome)
h_tbar=29

# Get active window ID
window=$(xdotool getactivewindow)

# Get window information - state, position, and size
windowstate=$(xprop -id $window | grep "_NET_WM_STATE" | grep -c "_NET_WM_STATE_MAXIMIZED")
x=$(xwininfo -id $window | grep "Absolute upper-left X" | awk '{print $4}')
y=$(xwininfo -id $window | grep "Absolute upper-left Y" | awk '{print $4}')
w=$(xwininfo -id $window | grep "Width" | awk '{print $2}')
h=$(xwininfo -id $window | grep "Height" | awk '{print $2}')

# Calculate window center
window_center_x=$((x + w/2))
window_center_y=$((y + h/2))

# Get all connected monitors' information
readarray -t monitor_output < <(xrandr --current | grep " connected")
monitor_count=${#monitor_output[@]}

if [ $monitor_count -lt 2 ]; then
    echo "Error: At least two monitors are required. Only $monitor_count found."
    exit 1
fi

# Parse monitor information
declare -a monitors
declare -a monitor_x_positions

echo "Detecting monitors..."
for ((i=0; i<$monitor_count; i++)); do
    # Get geometry from xrandr output
    geometry=$(echo "${monitor_output[$i]}" | grep -o "[0-9]\+x[0-9]\++[0-9]\++[0-9]\+")
    
    # If not found directly, try different approach
    if [ -z "$geometry" ]; then
        geometry=$(xrandr --current | grep -A1 "${monitor_output[$i]}" | grep -o "[0-9]\+x[0-9]\++[0-9]\++[0-9]\+")
    fi
    
    if [ -z "$geometry" ]; then
        echo "Error: Could not parse monitor geometry for monitor $i"
        echo "Raw output: ${monitor_output[$i]}"
        exit 1
    fi
    
    # Extract dimensions
    width=$(echo $geometry | cut -d'x' -f1)
    height=$(echo $geometry | cut -d'x' -f2 | cut -d'+' -f1)
    x_pos=$(echo $geometry | cut -d'+' -f2)
    y_pos=$(echo $geometry | cut -d'+' -f3)
    
    # Store monitor info as array: width,height,x,y
    monitors[$i]="$width,$height,$x_pos,$y_pos"
    monitor_x_positions[$i]=$x_pos
    
    echo "Monitor $i: ${width}x${height}+${x_pos}+${y_pos}"
done

# Find which monitor contains the window center
current_monitor_index=-1
for ((i=0; i<$monitor_count; i++)); do
    IFS=',' read -r mon_width mon_height mon_x mon_y <<< "${monitors[$i]}"
    
    # Check if window center is in this monitor
    if [ $window_center_x -ge $mon_x ] && 
       [ $window_center_x -le $((mon_x + mon_width)) ] && 
       [ $window_center_y -ge $mon_y ] && 
       [ $window_center_y -le $((mon_y + mon_height)) ]; then
        current_monitor_index=$i
        break
    fi
done

# If window wasn't found on any monitor, assume it's on monitor 0
if [ $current_monitor_index -eq -1 ]; then
    current_monitor_index=0
    echo "Window not detected on any monitor. Assuming monitor 0."
fi

# Sort monitors by x position to determine leftmost and rightmost
# Create an array of indices sorted by x positions
sorted_indices=()
for ((i=0; i<$monitor_count; i++)); do
    sorted_indices+=($i)
done

# Bubble sort the indices based on x positions
for ((i=0; i<$monitor_count; i++)); do
    for ((j=0; j<$((monitor_count-i-1)); j++)); do
        if [ ${monitor_x_positions[${sorted_indices[$j]}]} -gt ${monitor_x_positions[${sorted_indices[$j+1]}]} ]; then
            # Swap
            temp=${sorted_indices[$j]}
            sorted_indices[$j]=${sorted_indices[$j+1]}
            sorted_indices[$j+1]=$temp
        fi
    done
done

echo "Monitors sorted by position (left to right): ${sorted_indices[@]}"

# Find current monitor's position in the sorted list
current_sorted_position=-1
for ((i=0; i<$monitor_count; i++)); do
    if [ ${sorted_indices[$i]} -eq $current_monitor_index ]; then
        current_sorted_position=$i
        break
    fi
done

# Determine target monitor based on direction
target_monitor_index=-1

if [ "$DIRECTION" = "0" ]; then
    # Move to leftmost (index 0 in sorted list)
    target_monitor_index=${sorted_indices[0]}
    echo "Moving window to leftmost monitor (index $target_monitor_index)"
else
    # Move to rightmost (last index in sorted list)
    target_monitor_index=${sorted_indices[$((monitor_count-1))]}
    echo "Moving window to rightmost monitor (index $target_monitor_index)"
fi

# If already at target, exit
if [ $current_monitor_index -eq $target_monitor_index ]; then
    echo "Window is already on the target monitor. Nothing to do."
    exit 0
fi

# Get current and target monitor coordinates
IFS=',' read -r curr_width curr_height curr_x curr_y <<< "${monitors[$current_monitor_index]}"
IFS=',' read -r target_width target_height target_x target_y <<< "${monitors[$target_monitor_index]}"

# Calculate relative position on current monitor
rel_x=$((x - curr_x))
rel_y=$((y - curr_y))

# Calculate new position on target monitor
new_x=$((target_x + rel_x))
new_y=$((target_y + rel_y))

# Ensure window is fully visible on new monitor
# If window would go off right edge
if [ $((new_x + w)) -gt $((target_x + target_width)) ]; then
    overflow=$((new_x + w - target_x - target_width))
    new_x=$((new_x - overflow))
    # Ensure window is not moved off the left edge
    if [ $new_x -lt $target_x ]; then
        new_x=$target_x
        # If window is wider than monitor, resize it
        if [ $w -gt $target_width ]; then
            w=$target_width
        fi
    fi
fi

# If window is maximized, move and maximize on destination monitor
if [ $windowstate -gt 0 ]; then
    # First unmaximize if needed
    xdotool windowunmaximize $window
    
    # Move window to new monitor
    xdotool windowmove $window $new_x $new_y
    
    # Re-maximize window
    xdotool windowmaximize $window
else
    # Move window to new position
    xdotool windowmove $window $new_x $new_y
    
    # If window height is too large for target monitor, resize it
    if [ $h -gt $((target_height - h_tbar)) ]; then
        xdotool windowsize $window $w $((target_height - h_tbar))
    fi
fi

echo "Window moved successfully to monitor $target_monitor_index"