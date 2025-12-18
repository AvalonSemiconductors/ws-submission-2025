.. _vga:

TinyTapeout VGA Demos
=====================

Two copies of VGA Demos originally submitted to `TinyTapeout <https://www.tinytapeout.com>`__ are included to test the DACs at a high clock speed. Two demos are included at the following project IDs:

``'b00001``: `TinyTapeout animated logo <https://github.com/rejunity/ttgf-vga-tiny-tapeout-animated-logo>`__.

``'b00010``: `wafer.space animated screensaver <https://github.com/TinyTapeout/tt-waferspace-vga-screensaver>`__.

---------------
Pad Assignments
---------------

.. list-table:: Pad description
    :name: tt-vga-pad-description
    :header-rows: 1
    
    * - Pad
      - Name
      - Type
      - Summary
    * - ``bidir[0]``
      - ``RSTn``
      - I (PD)
      - Active low reset input
    * - ``bidir[26]``
      - ``R[1]``
      - O
      - Red digital color output
    * - ``bidir[27]``
      - ``G[1]``
      - O
      - Green digital color output
    * - ``bidir[28]``
      - ``B[1]``
      - O
      - Blue digital color output
    * - ``bidir[29]``
      - VSYNC
      - O
      - VGA vertical sync output
    * - ``bidir[30]``
      - ``R[0]``
      - O
      - Red digital color output
    * - ``bidir[31]``
      - ``G[0]``
      - O
      - Green digital color output
    * - ``bidir[32]``
      - ``B[0]``
      - O
      - Blue digital color output
    * - ``bidir[33]``
      - HSYNC
      - O
      - VGA horizontal sync output
    * - ``bidir[34]``
      - TILE¹
      - I
      - Enable Tiling
    * - ``bidir[35]``
      - SOLID¹
      - I
      - Use solid color instead of animated gradient
    * - ``bidir[38]``
      - GAMEPAD_LATCH¹
      - I
      - Gamepad PMOD latch pin
    * - ``bidir[39]``
      - GAMEPAD_CLK¹
      - I
      - Gamepad PMOD clock pin
    * - ``bidir[40]``
      - GAMEPAD_DATA¹
      - I
      - Gamepad PMOD Data
    * - ``analog[8]``
      - VGA Red
      - O
      - Red color channel
    * - ``analog[9]``
      - VGA Green
      - O
      - Green color channel
    * - ``analog[6]``
      - VGA Blue
      - O
      - Blue color channel

¹Exclusive to wafer.space screensaver demo

24-bit color VGA demo
=====================

This demo is supposed to show full 24-bit (8R8G8B) color output using the analog outputs. It has a different pinout than the TinyTapeout VGA demos. Only a simple test screen is displayed. This demo is found at project ID ``'b000101``.

---------------
Pad Assignments
---------------

.. list-table:: Pad description
    :name: vga-24bit-pad-description
    :header-rows: 1

    * - Pad
      - Name
      - Type
      - Summary    
    * - ``bidir[26]``
      - HSYNC
      - O
      - VGA horizontal sync output
    * - ``bidir[27]``
      - VSYNC
      - O
      - VGA vertical sync output
    * - ``analog[8]``
      - VGA Red
      - O
      - Red color channel
    * - ``analog[9]``
      - VGA Green
      - O
      - Green color channel
    * - ``analog[6]``
      - VGA Blue
      - O
      - Blue color channel
