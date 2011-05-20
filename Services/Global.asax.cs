using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.Diagnostics;
using Microsoft.Office.Interop.PowerPoint;

namespace TSN.Presentable.Services
{
    public class Global : System.Web.HttpApplication
    {
        internal const string PowerPointApplicationProgID = "PowerPoint.Application";
        internal const string PowerPointExePath = @"C:\Program Files (x86)\Microsoft Office\Office14\POWERPNT.EXE";
        internal const string WorkingDirectory = @"C:\Users\Public\Temp";


        internal static Process powerPointProc = new Process();
        internal static ProcessStartInfo processStartInfo = new ProcessStartInfo()
        {
            FileName = Global.PowerPointExePath,
            Arguments = String.Empty,
            WorkingDirectory = Global.WorkingDirectory,
            CreateNoWindow = true,
            WindowStyle = ProcessWindowStyle.Hidden
        };

        protected void Application_Start(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(powerPointProc.StartInfo.FileName))
            {
                powerPointProc.StartInfo = processStartInfo;
                powerPointProc.Start();
                powerPointProc.WaitForInputIdle();
            }
        }

        protected void Session_Start(object sender, EventArgs e)
        {

        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {

        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {

        }

        protected void Application_Error(object sender, EventArgs e)
        {

        }

        protected void Session_End(object sender, EventArgs e)
        {

        }

        protected void Application_End(object sender, EventArgs e)
        {
            if (powerPointProc != null)
            {
                powerPointProc.Kill();
                powerPointProc.Close();
                powerPointProc.Dispose();
                powerPointProc = null;
            }
        }
    }
}