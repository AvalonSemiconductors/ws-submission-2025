.. _ntsc:

NTSC Test
=========

Another experiment to use a DAC macro for video generation, this time by generating a black-and-white NTSC or PAL signal. This design generates all of the required NTSC or PAL synchronization signals on one of the analog outputs and overlays a test pattern in the active screen area. Several test patterns, both static and moving, are selectable through the Pattern Select pads. Only values 0 through 6 (inclusive) are valid for these inputs.

To generate a NTSC signal, the design must be clocked at exactly 14.31818MHz. For PAL, the required clock rate is 17.734475MHz.

The output of the analog pads on this chip swing between 0V and 5V at the recommended 5V supply voltage¹. However, both NTSC and PAL require a swing no larger than 0V to 1V. A resistor voltage divider of 12Kohm over 3.3Kohm should be sufficient for lowering the output voltage². A tank circuit may additionally be required.

¹Proper functioning of the DACs is not guranteed at lower voltages as all passive circuit components were tuned for 5V operation.

²The DACs cannot drive loads larger than 1Kohm, though degradation of the output signal occurs even earlier, so a value of >10Kohm is recommended for the first resistor.

---------------
Pad Assignments
---------------

.. list-table:: Pad description
    :name: ntsc-pad-description
    :header-rows: 1

    * - Pad
      - Name
      - Type
      - Summary
    * - ``bidir[11:0]``
      - ``luma[11:0]``
      - O
      - Copy of the digital luma value, as fed to the DAC internally
    * - ``bidir[35]``
      - PAL Select
      - I (PD)
      - When high, changes the sync timings to that of PAL instead of NTSC (a clock frequency adjustment is also required)
    * - ``bidir[40:37]``
      - Pattern Select
      - I (PD)
      - Binary input selecting the active test pattern
    * - ``bidir[41]``
      - ``RSTn``
      - I (PD)
      - Active-low design reset
    * - ``analog[4]``
      - ``luma``
      - O
      - Analog NTSC/PAL Luma Signal
