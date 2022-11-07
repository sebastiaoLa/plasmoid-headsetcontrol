#!/usr/bin/python3
import argparse
import sys

from collections import OrderedDict

# This is a pretty crude script to use instead of the actual HeadsetControl
# binary when we want to test the widget's look and feel with arbitrary
# values.
#
# Configure the plasmoid to use this script, and adjust the variables below
# as neededs. A bit primitive, but it works!

# If empty, will behave as if no USB receiver was plugged in.
MODEL="Dummy Headset"

# If false, will behave as if no headset was detected (i.e. headset is off).
AVAILABLE=True

# If not empty, will behave as if the features below were available. Supported
# letters in that string are:
#  - b (battery level)
#  - i (inactivity time)
#  - l (LEDs)
#  - m (chat-mix level)
#  - p (equalizer presets)
#  - r (rotate to mute)
#  - s (sidetone)
#  - v (voice prompts)
FEATURES="sbl"

# If AVAILABLE is True and MODEL not empty, will behave as if the headset was
# currently at the level of charge below. Use -1 for "Charging" status.
BATTERY=42

### Code starts here ###
capabilities = OrderedDict({
    's': "sidetone",
    'b': "battery status",
    'n': "notification sound",
    'l': "lights",
    'i': "inactive time",
    'm': "chatmix",
    'v': "voice prompts",
    'r': "rotate to mute",
    'p': "equalizer preset",
})

# Produce headsetcontrol-like output depending on config above.
parser = argparse.ArgumentParser(description = 'Mocks output from HeadsetControl for testing purposes.')
parser.add_argument('-?', '--capabilities', action='store_true')
parser.add_argument('-c', '--short-output', action='store_true')
parser.add_argument('-b', '--battery', action='store_true')
parser.add_argument('-n', '--notificate', type=int)
parser.add_argument('-l', '--light', type=int)
parser.add_argument('-i', '--inactive-time', type=int)
parser.add_argument('-m', '--chatmix', action='store_true')
parser.add_argument('-v', '--voice-prompt', type=int)
parser.add_argument('-r', '--rotate-to-mute', type=int)
parser.add_argument('-p', '--equalizer-preset', type=int)

# Return True if feature is defined, False otherwise.
def supported_feature(letter):
    if letter not in FEATURES:
        print("Error: This headset doesn't support %s" % capabilities[letter])
        return False
    return True

# -?, --capabilities
def query(args):
    if args.short_output:
        print(FEATURES, end='')
    else:
        print("Supported capabilities:\n")
        for f in FEATURES:
            print("* %s" % capabilities[f])
    return 0

# -b, --battery
def battery(args):
    # Error if unsupported feature.
    if not supported_feature('b'):
        return 1

    # If receiver is present but headset is off, this will fail.
    # Error message is what I get on my test box, probably not deterministic.
    if not AVAILABLE:
        print("Failed to set/request battery status. Error: -24: (null)")
        return 1

    if args.short_output:
        print("%d" % BATTERY, end='')
    else:
        print("Battery: %d%%" % BATTERY)
        print("Success!")
    return 0

# Generic command (that should be available from the pop-up).
#
# We're not really doing anything with those here. Maybe we should print
# something to confirm the command was executed.
def generic_command(feature):
    # Error if unsupported feature.
    if not supported_feature(feature):
        return 1

    # TODO: validate value.
    # TODO: define what happens if receiver is on, but headset is off.

    if not args.short_output:
        print("Success!")
    return 0

# The plasmoid only has three states: query model, then features, then battery.
if __name__ == "__main__":
    args = parser.parse_args()

    # If no receiver is present, nothing is shown.
    if not MODEL:
        print("No supported headset found")
        sys.exit(1)

    # By default, the model is displayed if short output isn't requested.
    if not args.short_output:
        print("Found %s!" % MODEL)

    if args.capabilities:
        sys.exit(query(args))

    if args.battery:
        sys.exit(battery(args))

    # Treat other args as generic commands. Those that can legitimately
    # take zero as a value need to be checked as "not None" for the `if`
    # block to work as intended.
    if args.notificate is not None:
        sys.exit(generic_command('n'))

    if args.light is not None:
        sys.exit(generic_command('l'))

    if args.inactive_time is not None:
        sys.exit(generic_command('i'))

    if args.chatmix:
        sys.exit(generic_command('m'))

    if args.voice_prompt is not None:
        sys.exit(generic_command('v'))

    if args.rotate_to_mute is not None:
        sys.exit(generic_command('r'))

    if args.equalizer_preset is not None:
        sys.exit(generic_command('p'))

    print(args)

    # Mimick default behavior if no arguments.
    if not args.short_output:
        print("You didn't set any arguments, so nothing happened.")
        print("Type %s -h for help." % sys.argv[0])

