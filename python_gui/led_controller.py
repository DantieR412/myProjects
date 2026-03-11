import tkinter as tk
from tkinter import ttk, messagebox
import serial
import serial.tools.list_ports
import time

port = None  # serial port object, starts as nothing

# Send one number over UART
def send(value):
    port.write(f"{value}\n".encode())
    time.sleep(0.3)

# Called when "Apply" is clicked
def apply():
    send(mode_var.get())
    send(speed_var.get())
    send(brightness_var.get())
    status.config(text=f"Sent: mode={mode_var.get()}  speed={speed_var.get()}  brightness={brightness_var.get()}", foreground="green")

# Called when "Connect" is clicked
def connect():
    global port
    try:
        port = serial.Serial(port_var.get(), 9600, timeout=2)
        status.config(text=f"Connected to {port_var.get()}", foreground="green")
        apply_btn.config(state="normal")
    except Exception as e:
        messagebox.showerror("Error", str(e))

# Build window
window = tk.Tk()
window.title("LED Controller")

# COM port picker
port_var = tk.StringVar()
ports = [p.device for p in serial.tools.list_ports.comports()]
ttk.Label(window, text="COM Port:").grid(row=0, column=0, padx=8, pady=6)
ttk.Combobox(window, textvariable=port_var, values=ports, width=10).grid(row=0, column=1)
ttk.Button(window, text="Connect", command=connect).grid(row=0, column=2, padx=8)

# Mode radio buttons
mode_var = tk.IntVar(value=1)
ttk.Label(window, text="Mode:").grid(row=1, column=0, padx=8, pady=(10,0), sticky="w")
for i, label in enumerate(["Off", "Running Light", "Blink", "Counter"]):
    ttk.Radiobutton(window, text=label, variable=mode_var, value=i).grid(row=2+i, column=0, columnspan=2, sticky="w", padx=16)

# Speed slider
speed_var = tk.IntVar(value=2)
ttk.Label(window, text="Speed (1-100):").grid(row=6, column=0, padx=8, pady=(10,0), sticky="w")
ttk.Scale(window, from_=1, to=100, variable=speed_var, orient="horizontal", length=180).grid(row=7, column=0, columnspan=2, padx=16)

# Brightness slider
brightness_var = tk.IntVar(value=128)
ttk.Label(window, text="Brightness (0-255):").grid(row=8, column=0, padx=8, pady=(10,0), sticky="w")
ttk.Scale(window, from_=0, to=255, variable=brightness_var, orient="horizontal", length=180).grid(row=9, column=0, columnspan=2, padx=16)

# Apply button + status label
apply_btn = ttk.Button(window, text="Apply", command=apply, state="disabled")
apply_btn.grid(row=10, column=0, columnspan=3, pady=14, ipadx=12, ipady=4)
status = ttk.Label(window, text="Not connected.", foreground="gray")
status.grid(row=11, column=0, columnspan=3, pady=(0,8))

window.mainloop()
