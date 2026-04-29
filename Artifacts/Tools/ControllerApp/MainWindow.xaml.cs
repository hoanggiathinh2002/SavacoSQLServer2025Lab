using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using Azure;
using Azure.Core;
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.DevTestLabs;
using Azure.ResourceManager.DevTestLabs.Models;
using Path = System.IO.Path;

namespace Lab_Controller
{
    public class LabItem
    {
        public string ID { get; set; }     // Used for paths (e.g., "07")
        public string Name { get; set; }   // Used for display
        public override string ToString() => Name;
    }

    public partial class MainWindow : Window
    {
        // --- AZURE CONFIGURATION ---
        // Replace these with your actual Azure portal values
        private const string SubscriptionId = "2ee7d06c-c16c-480f-80c4-9be21dee2330";
        private const string ResourceGroupName = "rg-thinh";
        private const string LabName = "SQL-Server-Lab-2025";
        private const string VirtualMachineName = "SQLServerLab02";
        // ---------------------------

        public MainWindow()
        {
            InitializeComponent();
            LoadLabs();
        }

        private void LoadLabs()
        {
            LabSelector.Items.Add(new LabItem { ID = "01", Name = "Lab 01: Introduction to SQL Server" });
            LabSelector.Items.Add(new LabItem { ID = "02", Name = "Lab 02: Installing and Configuring SQL Server" });
            LabSelector.Items.Add(new LabItem { ID = "03", Name = "Lab 03: Working with Databases and Storage" });
            LabSelector.Items.Add(new LabItem { ID = "04", Name = "Lab 04: Planning and Implementing a Backup Strategy" });
            LabSelector.Items.Add(new LabItem { ID = "05", Name = "Lab 05: Restoring SQL Server Databases" });
            LabSelector.Items.Add(new LabItem { ID = "06", Name = "Lab 06: Importing and Exporting Data" });
            LabSelector.Items.Add(new LabItem { ID = "07", Name = "Lab 07: Monitoring SQL Server" });
            LabSelector.Items.Add(new LabItem { ID = "08", Name = "Lab 08: Tracing SQL Server Activity" });
            LabSelector.Items.Add(new LabItem { ID = "09", Name = "Lab 09: Managing SQL Server Security" });
            LabSelector.Items.Add(new LabItem { ID = "10", Name = "Lab 10: Auditing Data Access and Encrypting Data" });
            LabSelector.Items.Add(new LabItem { ID = "11", Name = "Lab 11: Performing Ongoing Database Maintenance" });
            LabSelector.Items.Add(new LabItem { ID = "12", Name = "Lab 12: Automating SQL Server Management" });
            LabSelector.Items.Add(new LabItem { ID = "13", Name = "Lab 13: Monitoring SQL Server with Notifications" });
            LabSelector.SelectedIndex = 0;
        }

        private async void RunBtn_Click(object sender, RoutedEventArgs e)
        {
            var selectedLab = (LabItem)LabSelector.SelectedItem;
            if (selectedLab == null) return;

            // UI Lockdown
            RunBtn.IsEnabled = false;
            WorkProgress.IsIndeterminate = true;
            WorkProgress.Visibility = Visibility.Visible;

            try
            {
                // STEP 1: Local Configuration
                StatusText.Text = $"Running local setup for {selectedLab.Name}...";
                await Task.Run(() => SetupLab(selectedLab));

                // STEP 2: Azure Artifact Trigger
                StatusText.Text = "Connecting to Azure to apply artifacts...";
                await ApplyAzureArtifactAsync(selectedLab.ID);

                StatusText.Text = $"[SUCCESS] {selectedLab.Name} is fully configured.";
            }
            catch (Exception ex)
            {
                StatusText.Text = "[ERROR] Setup failed.";
                MessageBox.Show($"An error occurred: {ex.Message}", "Process Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            finally
            {
                WorkProgress.IsIndeterminate = false;
                WorkProgress.Visibility = Visibility.Hidden;
                RunBtn.IsEnabled = true;
            }
        }

        private async Task ApplyAzureArtifactAsync(string labId)
        {
            // DefaultAzureCredential picks up VS, Azure CLI, or Environment logins
            var client = new ArmClient(new DefaultAzureCredential());

            // Construct the Resource ID for the VM
            ResourceIdentifier vmResourceId = DevTestLabVmResource.CreateResourceIdentifier(
                SubscriptionId, ResourceGroupName, LabName, VirtualMachineName);

            DevTestLabVmResource labVm = client.GetDevTestLabVmResource(vmResourceId);

            var content = new DevTestLabVmApplyArtifactsContent();

            // Configure the artifact details. 
            // NOTE: Ensure the ArtifactId matches the name in your Azure Lab Repository
            var artifactInstallDetails = new DevTestLabArtifactInstallInfo()
            {
                //ArtifactId = $"Lab{labId}-Artifact" // Example: "Lab07-Artifact"
                ArtifactId = $"/subscriptions/{SubscriptionId}/resourceGroups/{ResourceGroupName}/providers/Microsoft.DevTestLab/labs/{LabName}/artifactSources/public repo/artifacts/Lab{labId}-Artifact"
            };


            content.Artifacts.Add(artifactInstallDetails);

            // Start the Azure Operation (LRO - Long Running Operation)
            ArmOperation operation = await labVm.ApplyArtifactsAsync(WaitUntil.Completed, content);
        }

        private void SetupLab(LabItem lab)
        {
            string labPath = $@"C:\SQLServerAdminLabs\Labfiles\Lab{lab.ID}\Starter";
            string bgDir = @"C:\SQLServerAdminLabs\Tools\BGInfo";

            // 1. Update BGInfo
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

            // 5. Run Setup.cmd
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

        private void TheoryBtn_Click(object sender, RoutedEventArgs e)
        {
            var selectedLab = (LabItem)LabSelector.SelectedItem;
            if (selectedLab == null) return;

            string theoryPath = $@"C:\SQLServerAdminLabs\Labfiles\Lab{selectedLab.ID}\Theory.pdf";

            if (File.Exists(theoryPath))
            {
                Process.Start(new ProcessStartInfo { FileName = theoryPath, UseShellExecute = true });
            }
            else
            {
                MessageBox.Show($"File missing: {theoryPath}");
            }
        }

        private void InstructionBtn_Click(object sender, RoutedEventArgs e)
        {
            var selectedLab = (LabItem)LabSelector.SelectedItem;
            if (selectedLab == null) return;

            string instructionPath = $@"C:\SQLServerAdminLabs\Labfiles\Lab{selectedLab.ID}\Instruction.pdf";

            if (File.Exists(instructionPath))
            {
                Process.Start(new ProcessStartInfo { FileName = instructionPath, UseShellExecute = true });
            }
            else
            {
                MessageBox.Show($"File missing: {instructionPath}");
            }
        }
    }
}