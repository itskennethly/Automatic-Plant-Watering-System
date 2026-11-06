package eecs;


import org.firmata4j.I2CDevice;
import org.firmata4j.IODevice;
import org.firmata4j.Pin;
import org.firmata4j.firmata.FirmataDevice;
import org.firmata4j.ssd1306.SSD1306;


import javax.swing.*;
import java.awt.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class AutoWatering {
    private static IODevice arduino;
    private static final int SOIL_SENSOR_PIN = 15; // A1
    private static final int PUMP_PIN = 2; // D2
    private static SSD1306 Display;
    private static final double REALLY_DRY_VALUE = 3.55;
    private static final double MOISTURE_THRESHOLD = 3.0;
    private static final double SATURATED_VALUE = 2.8;


    private static final ArrayList<DataPoint> moistureReadings = new ArrayList<>();
    private static GraphPanel graphPanel;


    public static void main(String[] args) {
        //Used for GUI Creation
        SwingUtilities.invokeLater(AutoWatering::createAndShowGUI);


        String portName = "COM3"; // COM3
        arduino = new FirmataDevice(portName);
        try {
            arduino.start();
            arduino.ensureInitializationIsDone();
            System.out.println("Connected to Arduino on " + portName);
            I2CDevice i2cObject = arduino.getI2CDevice((byte) 0x3C);  // OLED I2C address
            Display = new SSD1306(i2cObject, SSD1306.Size.SSD1306_128_64);
            Display.init();
            Display.getCanvas().drawString(0, 0, "EECS Main Project");
            Display.getCanvas().drawString(0, 16, "Watering System");
            Display.getCanvas().drawString(0, 32, "By: Kenneth Ly");
            Display.getCanvas().drawString(0, 48, "Number: 221324587");
            Display.display();
            Thread.sleep(4000);
            Display.clear();
            // Configure pins
            Pin soilSensor = arduino.getPin(SOIL_SENSOR_PIN);
            soilSensor.setMode(Pin.Mode.ANALOG);


            Pin pump = arduino.getPin(PUMP_PIN);
            pump.setMode(Pin.Mode.OUTPUT);


            System.out.println("Monitoring Soil Moisture...");


            long startTime = System.currentTimeMillis();


            while (true) {
                int rawValue = (int) soilSensor.getValue();
                double soilMoisture = (rawValue / 1023.0) * 5.0;


                // Display the reading
                System.out.printf("Soil Moisture: %.2f V\n", soilMoisture);


                // Add the reading and timestamp to the list for graphing
                long currentTime = System.currentTimeMillis() - startTime;
                moistureReadings.add(new DataPoint(soilMoisture, currentTime));
                if (moistureReadings.size() > 50) {
                    moistureReadings.remove(0);
                }
                //Graphing Panel to update readings
                SwingUtilities.invokeLater(() -> {
                    if (graphPanel != null) {
                        graphPanel.updateGraph(moistureReadings);
                    }
                });


                if (soilMoisture <= SATURATED_VALUE) {
                    System.out.println("Soil is wet. Pump OFF.");
                    pump.setValue(0);  // Turn pump OFF
                    updateDisplay("Pump: OFF");
                } else if (soilMoisture <= MOISTURE_THRESHOLD) {
                    System.out.println("Soil is moist. Pump ON.");
                    pump.setValue(1);  // Turn pump ON
                    updateDisplay("Pump: OFF");
                } else if (soilMoisture <= REALLY_DRY_VALUE) {
                    System.out.println("Soil is dry. Pump ON.");
                    pump.setValue(1);  // Turn pump ON
                    updateDisplay("Pump: ON");
                } else {
                    System.out.println("Air detected. Pump OFF.");
                    pump.setValue(0);  // Turn pump OFF
                    updateDisplay("Pump: OFF");
                }
                Thread.sleep(2000);
            }
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }


    private static void updateDisplay(String message) {
        Display.clear();  // Clear the display before updating
        Display.getCanvas().drawString(0, 0, "AutoWatering System");
        Display.getCanvas().drawString(0, 16, message);  // Display ON/OFF status
        Display.display();
    }


    public static void createAndShowGUI() {
        JFrame frame = new JFrame("Soil Moisture Graph");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(600, 400);


        graphPanel = new GraphPanel();
        frame.add(graphPanel);
        frame.setVisible(true);
    }
}


class DataPoint {
    double moisture;
    long timestamp;


    public DataPoint(double moisture, long timestamp) {
        this.moisture = moisture;
        this.timestamp = timestamp;
    }


    public double getMoisture() {
        return moisture;
    }


    public long getTimestamp() {
        return timestamp;
    }
}


class GraphPanel extends JPanel {
    private List<DataPoint> data = new ArrayList<>();


    public void updateGraph(List<DataPoint> newData) {
        this.data = new ArrayList<>(newData);
        repaint();
    }


    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);


        int width = getWidth() - 70;
        int height = getHeight() - 70;
        int xOffset = 60, yOffset = 60;
        double maxVal = 5.0;


        // Draw Axes
        g.setColor(Color.BLACK);
        g.drawLine(xOffset, getHeight() - yOffset, getWidth() - 20, getHeight() - yOffset); // X-axis
        g.drawLine(xOffset, 25, xOffset, getHeight() - yOffset); // Y-axis


        // Draw Labels
        g.drawString("Time (s)", getWidth() / 2 - 30, getHeight() - 20);
        g.drawString("Voltage (V)", 0, getHeight() / 2 - 25);


        // Draw Grid
        g.setColor(Color.LIGHT_GRAY);
        for (int i = 1; i <= 5; i++) {
            int y = getHeight() - yOffset - (int) ((i / 5.0) * height);
            g.drawLine(xOffset, y, getWidth() - 20, y);
            g.drawString(String.format("%.1f", (i * maxVal) / 5), 20, y);
        }


        if (data.isEmpty()) return;


        g.setColor(Color.BLUE);
        for (int i = 1; i < data.size(); i++) {
            int x1 = xOffset + ((i - 1) * width / data.size());
            int y1 = (int) ((1 - (data.get(i - 1).getMoisture() / maxVal)) * height) + 20;
            int x2 = xOffset + (i * width / data.size());
            int y2 = (int) ((1 - (data.get(i).getMoisture() / maxVal)) * height) + 20;




            g.drawLine(x1, y1, x2, y2);




            g.setColor(Color.RED);
            g.fillOval(x2 - 2, y2 - 2, 6, 6);
        }


        g.setColor(Color.BLACK);
        int labelStep = 2;
        for (int i = 0; i < data.size(); i++) {
            int x = xOffset + (i * width / data.size());
            if (i % labelStep == 0) {
                long timeInSec = data.get(i).getTimestamp() / 1000;
                g.drawString(String.valueOf(timeInSec), x, getHeight() - yOffset + 15);
            }
        }


        g.setColor(Color.BLACK);
        g.drawString("Soil Moisture Over Time", getWidth() / 2 - 50, 20);
        g.setColor(Color.RED);
        g.fillOval(10, 10, 6, 6);
        g.setColor(Color.BLACK);
        g.drawString("Data Points", 20, 20);
    }
}

