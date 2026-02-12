# MatLabC++ Quick Reference Card

## 🚀 Getting Started
```sh
cd /mnt/c/Users/Liam/Desktop/MatLabC++/build
./mlab++
```

## 📊 Variables
```matlab
x = 5              # Scalar
v = [1 2 3]        # Vector
M = [1 2; 3 4]     # Matrix
x = 5;             # Suppress output
```

## 🔧 Functions

### Display & Info
```matlab
disp(x)            # Display value
size(x)            # Dimensions
length(x)          # Length
```

### Statistics
```matlab
sum(x)             # Sum
mean(x)            # Average  
min(x)             # Minimum
max(x)             # Maximum
```

### Math
```matlab
sqrt(x)            # Square root
abs(x)             # Absolute value
sin(x), cos(x)     # Trig functions
exp(x), log(x)     # Exponential/log
```

## 🗂️ Workspace
```matlab
who                # List variables
whos               # Detailed info
clear              # Clear all
clear x            # Clear variable x
```

## 💻 System
```matlab
clc                # Clear screen
help               # Show help
quit               # Exit
```

## ✨ Examples
```matlab
# Create and analyze a vector
>> v = [1, 2, 3, 4, 5]
>> disp(sum(v))
>> disp(mean(v))

# Math operations
>> x = 16
>> disp(sqrt(x))

# Trigonometry
>> angle = 3.14159 / 2
>> disp(sin(angle))
```

---

**Tip:** Use semicolon `;` to suppress output!
