# Power Management

There are multiple methods of suspending available, notably:

Suspend to idle
    Called S0ix[dead link 2023-09-16 ⓘ] by Intel, Modern Standby (previously "Connected Standby") by Microsoft and S2Idle by the kernel. Designed to be used instead of the S3 sleeping state for supported systems, by providing identical energy savings but a drastically reduced wake-up time.
    Tip: While this state is subject to battery drain issues on Windows or macOS since they support waking devices in this state for network activity, the Linux software ecosystem does not currently make use of this feature and should be unaffected.
Suspend to RAM (aka suspend, aka sleep)
    The S3 sleeping state as defined by ACPI. Works by cutting off power to most parts of the machine aside from the RAM, which is required to restore the machine's state. Because of the large power savings, it is advisable for laptops to automatically enter this mode when the computer is running on batteries and the lid is closed (or the user is inactive for some time).
Suspend to disk (aka hibernate)
    The S4 sleeping state as defined by ACPI. Saves the machine's state into swap space and completely powers off the machine. When the machine is powered on, the state is restored. Until then, there is zero power consumption.
Hybrid suspend (aka hybrid sleep)
    A hybrid of suspending and hibernating, sometimes called suspend to both. Saves the machine's state into swap space, but does not power off the machine. Instead, it invokes the default suspend. Therefore, if the battery is not depleted, the system can resume instantly. If the battery is depleted, the system can be resumed from disk, which is much slower than resuming from RAM, but the machine's state has not been lost.
