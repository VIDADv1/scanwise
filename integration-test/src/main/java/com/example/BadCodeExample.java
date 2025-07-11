package com.example;

import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class BadCodeExample {

    // Hardcoded credentials
    private static final String USER = "admin";
    private static final String PASSWORD = "123456";

    // Unused variable
    private String unused = "not used";

    public static void main(String[] args) {
        System.out.println("Start");
        new BadCodeExample().connect(args.length > 0 ? args[0] : "");
    }

    public void connect(String name) {
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", USER, PASSWORD);
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM users WHERE name = '" + name + "'"); // SQL Injection

            while (rs.next()) {
                System.out.println("User: " + rs.getString("name"));
            }

            // resource not closed!
        } catch (Exception e) {
            e.printStackTrace(); // security hotspot
        }
    }

    public void writeFile() {
        try {
            FileWriter writer = new FileWriter("test.txt");
            writer.write("data"); // no close() -> resource leak
        } catch (IOException e) {
            // silent
        }
    }
}