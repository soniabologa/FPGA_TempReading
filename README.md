# FPGA Temperature Display with Alarm

This project reads the internal temperature of an FPGA using the XADC module and displays the value on a 2-digit 7-segment display. If the temperature exceeds 33°C, an alarm LED is triggered and latched until reset.

---

## Course Info

- **Course:** ECE238L – Computer Logic Design Lab  
- **Institution:** University of New Mexico  
- **Instructor:** Dr. Siamak Tavakoli  
- **Semester:** Spring 2025

---

## Project Description

The design utilizes the Xilinx Artix-7 FPGA's built-in XADC to read the on-chip temperature sensor. The temperature is processed and displayed in degrees Celsius on a multiplexed 7-segment display.

### Features

- Uses **XADC** to read FPGA's internal temperature
- Converts ADC value to Celsius
- Displays temperature on 2-digit 7-segment display (0–99°C)
- **Alarm LED (LED17)** latches on when temperature exceeds 33°C
- **Reset Switch (SW0)** to clear the alarm
- 0.5s temperature update rate via internal counter

### Inputs

- `CLK100MHZ`: Main clock input (100 MHz)
- `BTNC`: Center button (asynchronous reset)
- `SW0`: Manual switch to reset alarm

### Outputs

- `SEG[6:0]`: Segment display (active low)
- `AN[7:0]`: Anode control for digit multiplexing
- `LED17`: Alarm indicator

---

## How to Run

1. Open the project in **Vivado 2020.2** or compatible version.
2. Synthesize and implement the design.
3. Program your **Nexys A7** FPGA board.
4. Monitor the temperature displayed on the 7-segment display.
5. LED17 will light up when temperature exceeds 33°C.

---
- ** [Slides Presentation](https://docs.google.com/presentation/d/18yjhLdyuHura9bs64y-Zvk38DSmPZUvsE48sJkZUVrA/edit?slide=id.p1#slide=id.p1)**
- ** [Demo Video](https://photos.app.goo.gl/dpr5kYrzVfzq15AT6)**

