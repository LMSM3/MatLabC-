// MatLabC++ PowerShell Bridge v0.3.0
// C# Cmdlets with P/Invoke to native C functions
//
// Build: dotnet build
// Import: Import-Module .\MatLabCppPowerShell.dll
// Use: Get-Material aluminum_6061

using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;

namespace MatLabCppPowerShell
{
    #region P/Invoke Declarations

    /// <summary>
    /// Native interop with MatLabC++ C library
    /// </summary>
    public static class NativeBridge
    {
        private const string DllName = "matlabcpp_c_bridge";

        #region Material Functions

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr get_material_by_name(
            [MarshalAs(UnmanagedType.LPStr)] string name
        );

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr identify_material_by_density(
            double density,
            double tolerance
        );

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void free_material_result(IntPtr ptr);

        #endregion

        #region Constant Functions

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern double get_constant_by_name(
            [MarshalAs(UnmanagedType.LPStr)] string name
        );

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        [return: MarshalAs(UnmanagedType.I1)]
        public static extern bool constant_exists(
            [MarshalAs(UnmanagedType.LPStr)] string name
        );

        #endregion

        #region ODE Integration

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr integrate_simple_drop(
            double height,
            double mass,
            double drag_coefficient,
            ref int sample_count
        );

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void free_integration_result(IntPtr ptr);

        #endregion

        #region Matrix Operations

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr matrix_multiply(
            IntPtr A, int rows_A, int cols_A,
            IntPtr B, int rows_B, int cols_B,
            ref int rows_out, ref int cols_out
        );

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr solve_linear_system(
            IntPtr A, int n,
            IntPtr b,
            ref bool success
        );

        [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void free_matrix(IntPtr ptr);

        #endregion
    }

    #endregion

    #region Data Structures

    /// <summary>
    /// Material properties result
    /// </summary>
    public class MaterialInfo
    {
        public string Name { get; set; }
        public double Density { get; set; }          // kg/m³
        public double YoungsModulus { get; set; }    // Pa
        public double YieldStrength { get; set; }    // Pa
        public double ThermalConductivity { get; set; } // W/(m·K)
        public double SpecificHeat { get; set; }     // J/(kg·K)
        public double MeltingPoint { get; set; }     // K

        public override string ToString()
        {
            return $@"
Material: {Name}
  Density:              {Density:F0} kg/m³
  Young's Modulus:      {YoungsModulus / 1e9:F1} GPa
  Yield Strength:       {YieldStrength / 1e6:F1} MPa
  Thermal Conductivity: {ThermalConductivity:F1} W/(m·K)
  Specific Heat:        {SpecificHeat:F0} J/(kg·K)
  Melting Point:        {MeltingPoint - 273.15:F0}°C
";
        }
    }

    /// <summary>
    /// ODE integration sample
    /// </summary>
    public class IntegrationSample
    {
        public double Time { get; set; }
        public double PositionX { get; set; }
        public double PositionY { get; set; }
        public double PositionZ { get; set; }
        public double VelocityZ { get; set; }
    }

    #endregion

    #region Cmdlets

    /// <summary>
    /// Get-Material: Retrieve material properties by name
    /// </summary>
    /// <example>
    /// Get-Material aluminum_6061
    /// Get-Material steel | Format-Table
    /// </example>
    [Cmdlet(VerbsCommon.Get, "Material")]
    [OutputType(typeof(MaterialInfo))]
    public class GetMaterialCmdlet : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            HelpMessage = "Material name (e.g., aluminum_6061, steel, peek)"
        )]
        public string Name { get; set; }

        protected override void ProcessRecord()
        {
            try
            {
                IntPtr ptr = NativeBridge.get_material_by_name(Name);
                
                if (ptr == IntPtr.Zero)
                {
                    WriteError(new ErrorRecord(
                        new Exception($"Material '{Name}' not found"),
                        "MaterialNotFound",
                        ErrorCategory.ObjectNotFound,
                        Name
                    ));
                    return;
                }

                // Marshal material data
                var material = ParseMaterialPointer(ptr);
                NativeBridge.free_material_result(ptr);

                WriteObject(material);
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "NativeBridgeError",
                    ErrorCategory.InvalidOperation,
                    Name
                ));
            }
        }

        private MaterialInfo ParseMaterialPointer(IntPtr ptr)
        {
            // Parse C struct (implementation depends on C bridge layout)
            // This is a simplified example
            return new MaterialInfo
            {
                Name = Marshal.PtrToStringAnsi(Marshal.ReadIntPtr(ptr, 0)),
                Density = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(ptr, 8)),
                YoungsModulus = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(ptr, 16)),
                YieldStrength = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(ptr, 24)),
                ThermalConductivity = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(ptr, 32)),
                SpecificHeat = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(ptr, 40)),
                MeltingPoint = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(ptr, 48))
            };
        }
    }

    /// <summary>
    /// Find-Material: Identify material by density
    /// </summary>
    /// <example>
    /// Find-Material 2700
    /// Find-Material 2700 -Tolerance 100
    /// </example>
    [Cmdlet(VerbsCommon.Find, "Material")]
    [OutputType(typeof(MaterialInfo))]
    public class FindMaterialCmdlet : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Density in kg/m³"
        )]
        public double Density { get; set; }

        [Parameter(
            Position = 1,
            HelpMessage = "Tolerance (default 100 kg/m³)"
        )]
        public double Tolerance { get; set; } = 100.0;

        protected override void ProcessRecord()
        {
            try
            {
                IntPtr ptr = NativeBridge.identify_material_by_density(Density, Tolerance);
                
                if (ptr == IntPtr.Zero)
                {
                    WriteWarning($"No material found with density {Density} ± {Tolerance} kg/m³");
                    return;
                }

                var material = ParseMaterialPointer(ptr);
                NativeBridge.free_material_result(ptr);

                WriteObject(material);
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "IdentificationError",
                    ErrorCategory.InvalidOperation,
                    Density
                ));
            }
        }

        private MaterialInfo ParseMaterialPointer(IntPtr ptr)
        {
            // Same as GetMaterialCmdlet
            return new MaterialInfo
            {
                Name = Marshal.PtrToStringAnsi(Marshal.ReadIntPtr(ptr, 0)),
                Density = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(ptr, 8)),
                // ... other fields
            };
        }
    }

    /// <summary>
    /// Get-Constant: Retrieve physical constant by name
    /// </summary>
    /// <example>
    /// Get-Constant g
    /// Get-Constant pi
    /// </example>
    [Cmdlet(VerbsCommon.Get, "Constant")]
    [OutputType(typeof(double))]
    public class GetConstantCmdlet : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            HelpMessage = "Constant name (g, pi, c, h, k_B, etc.)"
        )]
        public string Name { get; set; }

        protected override void ProcessRecord()
        {
            try
            {
                if (!NativeBridge.constant_exists(Name))
                {
                    WriteError(new ErrorRecord(
                        new Exception($"Constant '{Name}' not found"),
                        "ConstantNotFound",
                        ErrorCategory.ObjectNotFound,
                        Name
                    ));
                    return;
                }

                double value = NativeBridge.get_constant_by_name(Name);
                
                WriteObject(new PSObject(value));
                WriteVerbose($"{Name} = {value}");
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "ConstantLookupError",
                    ErrorCategory.InvalidOperation,
                    Name
                ));
            }
        }
    }

    /// <summary>
    /// Invoke-ODEIntegration: Simulate dropping object
    /// </summary>
    /// <example>
    /// Invoke-ODEIntegration -Height 100 -Mass 1.0
    /// </example>
    [Cmdlet(VerbsLifecycle.Invoke, "ODEIntegration")]
    [OutputType(typeof(IntegrationSample[]))]
    public class InvokeODEIntegrationCmdlet : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            HelpMessage = "Drop height in meters"
        )]
        public double Height { get; set; }

        [Parameter(
            HelpMessage = "Mass in kg (default 1.0)"
        )]
        public double Mass { get; set; } = 1.0;

        [Parameter(
            HelpMessage = "Drag coefficient (default 0.47 for sphere)"
        )]
        public double DragCoefficient { get; set; } = 0.47;

        protected override void ProcessRecord()
        {
            try
            {
                int sampleCount = 0;
                IntPtr ptr = NativeBridge.integrate_simple_drop(
                    Height,
                    Mass,
                    DragCoefficient,
                    ref sampleCount
                );

                if (ptr == IntPtr.Zero || sampleCount == 0)
                {
                    WriteWarning("Integration failed or returned no samples");
                    return;
                }

                // Parse samples
                var samples = new IntegrationSample[sampleCount];
                int sampleSize = Marshal.SizeOf<double>() * 5; // time, px, py, pz, vz

                for (int i = 0; i < sampleCount; i++)
                {
                    IntPtr samplePtr = IntPtr.Add(ptr, i * sampleSize);
                    samples[i] = new IntegrationSample
                    {
                        Time = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(samplePtr, 0)),
                        PositionX = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(samplePtr, 8)),
                        PositionY = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(samplePtr, 16)),
                        PositionZ = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(samplePtr, 24)),
                        VelocityZ = BitConverter.Int64BitsToDouble(Marshal.ReadInt64(samplePtr, 32))
                    };
                }

                NativeBridge.free_integration_result(ptr);

                WriteObject(samples, true);
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "IntegrationError",
                    ErrorCategory.InvalidOperation,
                    Height
                ));
            }
        }
    }

    /// <summary>
    /// Invoke-MatrixMultiply: Multiply two matrices
    /// </summary>
    /// <example>
    /// $A = @(@(1,2), @(3,4))
    /// $B = @(@(5,6), @(7,8))
    /// Invoke-MatrixMultiply $A $B
    /// </example>
    [Cmdlet(VerbsLifecycle.Invoke, "MatrixMultiply")]
    [Alias("matmul")]
    [OutputType(typeof(double[][]))]
    public class InvokeMatrixMultiplyCmdlet : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public double[][] A { get; set; }

        [Parameter(Mandatory = true, Position = 1)]
        public double[][] B { get; set; }

        protected override void ProcessRecord()
        {
            try
            {
                // Flatten arrays for P/Invoke
                int rowsA = A.Length;
                int colsA = A[0].Length;
                int rowsB = B.Length;
                int colsB = B[0].Length;

                if (colsA != rowsB)
                {
                    WriteError(new ErrorRecord(
                        new Exception($"Dimension mismatch: A is {rowsA}x{colsA}, B is {rowsB}x{colsB}"),
                        "DimensionMismatch",
                        ErrorCategory.InvalidArgument,
                        null
                    ));
                    return;
                }

                // Marshal to native arrays
                IntPtr ptrA = MarshalMatrix(A, rowsA, colsA);
                IntPtr ptrB = MarshalMatrix(B, rowsB, colsB);

                int rowsOut = 0, colsOut = 0;
                IntPtr ptrC = NativeBridge.matrix_multiply(
                    ptrA, rowsA, colsA,
                    ptrB, rowsB, colsB,
                    ref rowsOut, ref colsOut
                );

                // Unmarshal result
                double[][] C = UnmarshalMatrix(ptrC, rowsOut, colsOut);

                // Free native memory
                Marshal.FreeHGlobal(ptrA);
                Marshal.FreeHGlobal(ptrB);
                NativeBridge.free_matrix(ptrC);

                WriteObject(C, true);
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "MatrixMultiplyError",
                    ErrorCategory.InvalidOperation,
                    null
                ));
            }
        }

        private IntPtr MarshalMatrix(double[][] matrix, int rows, int cols)
        {
            int size = rows * cols * sizeof(double);
            IntPtr ptr = Marshal.AllocHGlobal(size);
            
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    Marshal.WriteInt64(
                        ptr,
                        (i * cols + j) * sizeof(double),
                        BitConverter.DoubleToInt64Bits(matrix[i][j])
                    );
                }
            }

            return ptr;
        }

        private double[][] UnmarshalMatrix(IntPtr ptr, int rows, int cols)
        {
            double[][] matrix = new double[rows][];
            
            for (int i = 0; i < rows; i++)
            {
                matrix[i] = new double[cols];
                for (int j = 0; j < cols; j++)
                {
                    long bits = Marshal.ReadInt64(ptr, (i * cols + j) * sizeof(double));
                    matrix[i][j] = BitConverter.Int64BitsToDouble(bits);
                }
            }

            return matrix;
        }
    }

    #endregion
}
