using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using System.Drawing;
using System.Net;

namespace MatLabCppBuilder
{
    public class BuilderGUI : Form
    {
        private TextBox outputBox;
        private Button btnBuildNative;
        private Button btnBuildCSharp;
        private Button btnBuildAll;
        private Button btnInstallGCC;
        private ProgressBar progressBar;
        private Label statusLabel;
        private Panel topPanel;
        
        private string workingDir;
        
        public BuilderGUI()
        {
            InitializeUI();
            workingDir = Directory.GetCurrentDirectory();
        }
        
        private void InitializeUI()
        {
            // Window setup
            this.Text = "MatLabC++ Builder - Windows GUI";
            this.Size = new Size(800, 600);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.BackColor = Color.FromArgb(30, 30, 30);
            this.ForeColor = Color.White;
            
            // Top panel with buttons
            topPanel = new Panel
            {
                Dock = DockStyle.Top,
                Height = 120,
                BackColor = Color.FromArgb(45, 45, 45),
                Padding = new Padding(10)
            };
            
            // Build All button (big and prominent)
            btnBuildAll = new Button
            {
                Text = "🚀 BUILD EVERYTHING",
                Size = new Size(200, 50),
                Location = new Point(10, 10),
                Font = new Font("Segoe UI", 12, FontStyle.Bold),
                BackColor = Color.FromArgb(0, 120, 215),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand
            };
            btnBuildAll.FlatAppearance.BorderSize = 0;
            btnBuildAll.Click += BtnBuildAll_Click;
            
            // Build Native button
            btnBuildNative = new Button
            {
                Text = "Build Native (.dll)",
                Size = new Size(150, 40),
                Location = new Point(220, 10),
                BackColor = Color.FromArgb(60, 60, 60),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat
            };
            btnBuildNative.Click += BtnBuildNative_Click;
            
            // Build C# button
            btnBuildCSharp = new Button
            {
                Text = "Build C# Module",
                Size = new Size(150, 40),
                Location = new Point(380, 10),
                BackColor = Color.FromArgb(60, 60, 60),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat
            };
            btnBuildCSharp.Click += BtnBuildCSharp_Click;
            
            // Install GCC button
            btnInstallGCC = new Button
            {
                Text = "⚙️ Install MinGW-GCC",
                Size = new Size(150, 40),
                Location = new Point(540, 10),
                BackColor = Color.FromArgb(204, 122, 0),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat
            };
            btnInstallGCC.Click += BtnInstallGCC_Click;
            
            // Status label
            statusLabel = new Label
            {
                Text = "Ready to build",
                Location = new Point(10, 60),
                Size = new Size(700, 20),
                ForeColor = Color.LightGreen,
                Font = new Font("Consolas", 10)
            };
            
            // Progress bar
            progressBar = new ProgressBar
            {
                Location = new Point(10, 85),
                Size = new Size(700, 20),
                Style = ProgressBarStyle.Continuous
            };
            
            // Output text box
            outputBox = new TextBox
            {
                Multiline = true,
                Dock = DockStyle.Fill,
                ScrollBars = ScrollBars.Vertical,
                Font = new Font("Consolas", 9),
                BackColor = Color.Black,
                ForeColor = Color.LightGreen,
                ReadOnly = true,
                BorderStyle = BorderStyle.None
            };
            
            // Add controls
            topPanel.Controls.AddRange(new Control[] {
                btnBuildAll, btnBuildNative, btnBuildCSharp, btnInstallGCC,
                statusLabel, progressBar
            });
            
            this.Controls.Add(outputBox);
            this.Controls.Add(topPanel);
            
            // Welcome message
            LogOutput("╔═══════════════════════════════════════════════════╗");
            LogOutput("║  MatLabC++ Builder - Windows GUI v1.0            ║");
            LogOutput("╚═══════════════════════════════════════════════════╝");
            LogOutput("");
            LogOutput("Click 'BUILD EVERYTHING' to get started!");
            LogOutput("");
            
            CheckEnvironment();
        }
        
        private void CheckEnvironment()
        {
            LogOutput("Checking build environment...");
            
            // Check for .NET SDK
            if (CheckCommand("dotnet", "--version"))
            {
                LogOutput("✓ .NET SDK found");
            }
            else
            {
                LogOutput("✗ .NET SDK not found - required for C# build");
            }
            
            // Check for GCC
            if (CheckCommand("gcc", "--version"))
            {
                LogOutput("✓ GCC found");
            }
            else
            {
                LogOutput("✗ GCC not found - click 'Install MinGW-GCC' button");
            }
            
            // Check for matlabcpp_c_bridge.c
            if (File.Exists("matlabcpp_c_bridge.c"))
            {
                LogOutput("✓ Source file found: matlabcpp_c_bridge.c");
            }
            else
            {
                LogOutput("✗ Source file not found");
            }
            
            LogOutput("");
        }
        
        private bool CheckCommand(string command, string args)
        {
            try
            {
                var psi = new ProcessStartInfo
                {
                    FileName = command,
                    Arguments = args,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true
                };
                
                using (var proc = Process.Start(psi))
                {
                    proc.WaitForExit(2000);
                    return proc.ExitCode == 0;
                }
            }
            catch
            {
                return false;
            }
        }
        
        private void BtnBuildAll_Click(object sender, EventArgs e)
        {
            LogOutput("");
            LogOutput("═══════════════════════════════════════");
            LogOutput("  Starting Full Build Process");
            LogOutput("═══════════════════════════════════════");
            
            statusLabel.Text = "Building...";
            progressBar.Value = 0;
            
            // Step 1: Build Native
            progressBar.Value = 10;
            if (!BuildNative())
            {
                statusLabel.Text = "Build failed - check output";
                statusLabel.ForeColor = Color.Red;
                return;
            }
            
            // Step 2: Build C#
            progressBar.Value = 50;
            if (!BuildCSharp())
            {
                statusLabel.Text = "Build failed - check output";
                statusLabel.ForeColor = Color.Red;
                return;
            }
            
            progressBar.Value = 100;
            statusLabel.Text = "✓ Build complete!";
            statusLabel.ForeColor = Color.LightGreen;
            
            LogOutput("");
            LogOutput("✓ BUILD COMPLETE!");
            LogOutput("Ready to use: Import-Module .\\bin\\Release\\net6.0\\MatLabCppPowerShell.dll");
            
            MessageBox.Show(
                "Build successful!\n\nYou can now run:\nImport-Module .\\bin\\Release\\net6.0\\MatLabCppPowerShell.dll",
                "Success",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information
            );
        }
        
        private void BtnBuildNative_Click(object sender, EventArgs e)
        {
            BuildNative();
        }
        
        private void BtnBuildCSharp_Click(object sender, EventArgs e)
        {
            BuildCSharp();
        }
        
        private bool BuildNative()
        {
            LogOutput("");
            LogOutput("[1/2] Building native library...");
            
            if (!File.Exists("matlabcpp_c_bridge.c"))
            {
                LogOutput("✗ Error: matlabcpp_c_bridge.c not found");
                return false;
            }
            
            // Try GCC first
            string output = RunCommand("gcc", "-shared -O2 -o matlabcpp_c_bridge.dll matlabcpp_c_bridge.c -I..\\include -lm");
            
            if (File.Exists("matlabcpp_c_bridge.dll"))
            {
                LogOutput("✓ Native library built: matlabcpp_c_bridge.dll");
                
                // Copy to bin dirs
                CopyToOutputDirs("matlabcpp_c_bridge.dll");
                
                return true;
            }
            else
            {
                LogOutput("✗ Build failed. Output:");
                LogOutput(output);
                return false;
            }
        }
        
        private bool BuildCSharp()
        {
            LogOutput("");
            LogOutput("[2/2] Building C# module...");
            
            string output = RunCommand("dotnet", "build -c Release");
            LogOutput(output);
            
            if (Directory.Exists("bin\\Release\\net6.0"))
            {
                LogOutput("✓ C# module built successfully");
                return true;
            }
            else
            {
                LogOutput("✗ C# build failed");
                return false;
            }
        }
        
        private void CopyToOutputDirs(string filename)
        {
            string[] dirs = { "bin\\Debug\\net6.0", "bin\\Release\\net6.0" };
            
            foreach (var dir in dirs)
            {
                if (Directory.Exists(dir))
                {
                    File.Copy(filename, Path.Combine(dir, filename), true);
                    LogOutput($"  ✓ Copied to {dir}");
                }
            }
        }
        
        private void BtnInstallGCC_Click(object sender, EventArgs e)
        {
            var result = MessageBox.Show(
                "This will open the MinGW-w64 download page.\n\n" +
                "Recommended: Download the online installer and install to C:\\mingw64\n\n" +
                "After installation, add C:\\mingw64\\bin to your PATH.\n\n" +
                "Open download page?",
                "Install MinGW-GCC",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question
            );
            
            if (result == DialogResult.Yes)
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = "https://github.com/niXman/mingw-builds-binaries/releases",
                    UseShellExecute = true
                });
                
                LogOutput("Opening MinGW download page...");
                LogOutput("After install, restart this app and click 'BUILD EVERYTHING'");
            }
        }
        
        private string RunCommand(string command, string args)
        {
            try
            {
                var psi = new ProcessStartInfo
                {
                    FileName = command,
                    Arguments = args,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    WorkingDirectory = workingDir
                };
                
                using (var proc = Process.Start(psi))
                {
                    string output = proc.StandardOutput.ReadToEnd();
                    string error = proc.StandardError.ReadToEnd();
                    proc.WaitForExit();
                    
                    return output + error;
                }
            }
            catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }
        
        private void LogOutput(string message)
        {
            if (outputBox.InvokeRequired)
            {
                outputBox.Invoke(new Action(() => LogOutput(message)));
            }
            else
            {
                outputBox.AppendText(message + Environment.NewLine);
                outputBox.SelectionStart = outputBox.Text.Length;
                outputBox.ScrollToCaret();
            }
        }
    }
    
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new BuilderGUI());
        }
    }
}
