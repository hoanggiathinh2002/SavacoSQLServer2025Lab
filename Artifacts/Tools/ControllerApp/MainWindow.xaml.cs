using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Path = System.IO.Path;

namespace Lab_Controller
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public class LabItem
    {
        public string ID { get; set; }     // Used for paths (e.g., "07")
        public string Name { get; set; }   // Used for display (e.g., "Lab 07: Monitoring SQL Server")

        public override string ToString() => Name; // What shows in the ComboBox
    }
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            LoadLabs();
        }
        private void LoadLabs()
        {
            // Add your labs here: ID is for folders, Name is for the user
            LabSelector.Items.Add(new LabItem { ID = "01", Name = "Lab 01: Introduction to SQL Server Database Administration" });
            LabSelector.Items.Add(new LabItem { ID = "02", Name = "Lab 02: Installing and Configuring SQL Server" });
            LabSelector.Items.Add(new LabItem { ID = "03", Name = "Lab 03: Working with Databases and Storage" });
            LabSelector.Items.Add(new LabItem { ID = "04", Name = "Lab 04: Planning and Implementing a Backup Strategy" });
            LabSelector.Items.Add(new LabItem { ID = "05", Name = "Lab 05: Restoring SQL Server Databases" });
            LabSelector.Items.Add(new LabItem { ID = "06", Name = "Lab 06: Importing and Exporting Data" });
            LabSelector.Items.Add(new LabItem { ID = "07", Name = "Lab 07: Monitoring SQL Server" });
            LabSelector.Items.Add(new LabItem { ID = "08", Name = "Lab 08: Tracing SQL Server Activity" });
            LabSelector.Items.Add(new LabItem { ID = "09", Name = "Lab 09: Managing SQL Server Security" });
            LabSelector.Items.Add(new LabItem { ID = "10", Name = "Lab 10: Auditing Data Access and Encrypting Data" });
            LabSelector.Items.Add(new LabItem { ID = "11", Name = "Lab 11: Performing Ongoing Database Maintenance " });
            LabSelector.Items.Add(new LabItem { ID = "12", Name = "Lab 12: Automating SQL Server Management" });
            LabSelector.Items.Add(new LabItem { ID = "13", Name = "Lab 13: Monitoring SQL Server with Notifications and Alerts" });
            LabSelector.SelectedIndex = 0;
        }

        private async void RunBtn_Click(object sender, RoutedEventArgs e)
        {
            var selectedLab = (LabItem)LabSelector.SelectedItem;

            // UI Updates
            RunBtn.IsEnabled = false;
            WorkProgress.IsIndeterminate = true;
            WorkProgress.Visibility = Visibility.Visible;
            StatusText.Text = $"Configuring {selectedLab.Name}...";

            await Task.Run(() => SetupLab(selectedLab));

            // Completion
            WorkProgress.IsIndeterminate = false;
            WorkProgress.Visibility = Visibility.Hidden;
            StatusText.Text = $"[SUCCESS] {selectedLab.Name} is now active.";
            RunBtn.IsEnabled = true;
        }
        private void TheoryBtn_Click(object sender, RoutedEventArgs e)
        {
            var selectedLab = (LabItem)LabSelector.SelectedItem;
            if (selectedLab == null) return;

            // Define where your theory files are located. 
            // Example: C:\SQLServerAdminLabs\Labfiles\Lab01\Theory.pdf
            string theoryPath = $@"C:\SQLServerAdminLabs\Labfiles\Lab{selectedLab.ID}\Theory.pdf";

            if (File.Exists(theoryPath))
            {
                try
                {
                    Process.Start(new ProcessStartInfo
                    {
                        FileName = theoryPath,
                        UseShellExecute = true // This tells Windows to open it with the default PDF reader
                    });
                    StatusText.Text = "Opening theory document...";
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Could not open theory file: {ex.Message}");
                }
            }
            else
            {
                MessageBox.Show($"Theory document not found at: {theoryPath}", "File Missing");
            }
        }
        private void SetupLab(LabItem lab)
        {
            // PATHS use the ID (e.g., "07")
            string labPath = $@"C:\SQLServerAdminLabs\Labfiles\Lab{lab.ID}\Starter";
            string bgDir = @"C:\SQLServerAdminLabs\Tools\BGInfo";

            // 1. Update BGInfo with the full Name (e.g., "Lab 07: Monitoring SQL Server")
            File.WriteAllText(Path.Combine(bgDir, "CurrentLab.txt"), lab.Name);

            // 2. Stop Services
            RunCommand("net", "stop SQLSERVERAGENT /y");
            RunCommand("net", "stop MSSQLSERVER /y");

            // 3. File Cleanup
            if (Directory.Exists(@"C:\Backups"))
            {
                foreach (var file in Directory.GetFiles(@"C:\Backups", "*.bak"))
                    try { File.Delete(file); } catch { }
            }

            // 4. Start & Deep Clean
            RunCommand("net", "start MSSQLSERVER");
            RunCommand("sqlcmd", "-S localhost -E -i \"C:\\SQLServerAdminLabs\\Tools\\DeepClean.sql\"");

            // 5. Run Setup using the ID-based path
            string setupFile = Path.Combine(labPath, "Setup.cmd");
            if (File.Exists(setupFile))
            {
                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = setupFile,
                    WorkingDirectory = labPath,
                    Verb = "runas",
                    UseShellExecute = true
                };
                Process.Start(psi)?.WaitForExit();
            }

            // 6. Refresh Background
            Process.Start(Path.Combine(bgDir, "bginfo64.exe"), $"\"{bgDir}\\LabSetup.bgi\" /timer:0 /nolicprompt /silent");
        }

        private void RunCommand(string cmd, string args)
        {
            var psi = new ProcessStartInfo(cmd, args) { CreateNoWindow = true, WindowStyle = ProcessWindowStyle.Hidden };
            Process.Start(psi)?.WaitForExit();
        }
    }
}
