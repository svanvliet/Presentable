using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

using Microsoft.Office.Interop.PowerPoint;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Microsoft.Office.Core;

namespace DocumentConversionService
{
    /// <summary>
    /// 
    /// </summary>
    public class DocumentConverter : IDocumentConverter
    {
        public struct TraceCategory
        {
            public const string PerformanceDiagnostics = "Performance Diagnostics";
            public const string Exceptions = "Exceptions";
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="docBinary"></param>
        /// <param name="fileNameWithExt"></param>
        /// <returns></returns>
        public byte[] RenderAsPdf(byte[] docBinary, string fileNameWithExt)
        {
            DateTime startDateTime = DateTime.Now;
            byte[] outputBinary = default(byte[]);

            string fileExt = fileNameWithExt.Split('.').LastOrDefault<string>();
            if (fileExt == default(string))
            {
                Trace.WriteLine(String.Format(
                    "Could not determine file type of file named \"{0}\".",
                    fileNameWithExt),
                    TraceCategory.Exceptions);

                throw new ArgumentException(
                    String.Format(
                        "The specified file name did not have a proper extension; file type could not be determined, param value \"{0}\".",
                        fileNameWithExt),
                        "fileNameWithExt");
            }
            
            string fileExtCheckValue = 
                Enum.GetNames(typeof(DocumentType)).FirstOrDefault<string>(
                    t => t.Equals(fileExt, StringComparison.CurrentCultureIgnoreCase));

            if (fileExtCheckValue == default(string))
            {
                Trace.WriteLine(String.Format(
                    "Could not find the file extension within the DocumentType enum; file extension discovered was \"{0}\".",
                    fileExt),
                    TraceCategory.Exceptions);

                throw new ArgumentException(
                    String.Format(
                        "The specified file, with extension \"{0}\", is not supported by this service",
                        fileExt),
                        "fileNameWithExt");
            }

            DocumentType docType = DocumentType.NotSet;
            switch (fileExt)
            {
                case "ppt":
                    docType = DocumentType.Ppt;
                    break;
                case "pptx":
                    docType = DocumentType.Pptx;
                    break;
                case "doc":
                    docType = DocumentType.Doc;
                    break;
                case "docx":
                    docType = DocumentType.Docx;
                    break;
                default:
                    throw new NotImplementedException();
            }

            outputBinary = RenderAsPdf(docBinary, docType);

            DateTime endDateTime = DateTime.Now;
            TimeSpan duration = endDateTime - startDateTime;

            Trace.WriteLine(String.Format(
                "DocumentConverter.RenderAsPdf(byte[] docBinary, string fileNameWithExt) took {0} ms to process.",
                duration.Milliseconds),
                TraceCategory.PerformanceDiagnostics);

            return outputBinary;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="docBinary"></param>
        /// <param name="docType"></param>
        /// <returns></returns>
        public byte[] RenderAsPdf(byte[] docBinary, DocumentType docType)
        {
            switch (docType)
            {
                case DocumentType.Ppt:
                    return RenderPowerPoint(docBinary, docType, OutputFormatType.Pdf);
                case DocumentType.Pptx:
                    return RenderPowerPoint(docBinary, docType, OutputFormatType.Pdf);
                case DocumentType.Doc:
                    return RenderWordDocument(docBinary, docType, OutputFormatType.Pdf);
                case DocumentType.Docx:
                    return RenderWordDocument(docBinary, docType, OutputFormatType.Pdf);
                default:
                    throw new NotImplementedException();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="docBinary"></param>
        /// <param name="docType"></param>
        /// <param name="outputType"></param>
        /// <returns></returns>
        private byte[] RenderPowerPoint(byte[] docBinary, DocumentType docType, OutputFormatType outputType)
        {
            Process powerPointProc = null;
            Application powerPointApp = null;
            Presentation powerPointPreso = null;

            Guid workingDocID = Guid.Empty;

            try
            {
                workingDocID = Guid.NewGuid();

                var inputFileNameAndPath = String.Format(@"{0}\{1}.{2}", Global.WorkingDirectory, workingDocID, Enum.GetName(typeof(DocumentType), docType).ToLower());
                var outputFileNameAndPath = String.Format(@"{0}\{1}.pdf", Global.WorkingDirectory, workingDocID);

                File.WriteAllBytes(inputFileNameAndPath, docBinary);

                var processStartInfo = new ProcessStartInfo()
                {
                    FileName = Global.PowerPointExePath,
                    Arguments = String.Empty,
                    WorkingDirectory = Global.WorkingDirectory,
                    CreateNoWindow = true,
                    WindowStyle = ProcessWindowStyle.Hidden
                };
                
                powerPointProc = Process.Start(processStartInfo);
                powerPointProc.WaitForInputIdle();

                powerPointApp = Activator.CreateInstance(Type.GetTypeFromProgID(Global.PowerPointApplicationProgID)) as ApplicationClass;

                powerPointPreso = powerPointApp.Presentations.Open2007(inputFileNameAndPath, MsoTriState.msoTrue);
                powerPointPreso.ExportAsFixedFormat(outputFileNameAndPath, PpFixedFormatType.ppFixedFormatTypePDF);

                return File.ReadAllBytes(outputFileNameAndPath);
            }
            finally
            {
                if (powerPointPreso != null)
                {
                    powerPointPreso.Close();
                    powerPointPreso = null;
                }

                if (powerPointApp != null)
                {
                    powerPointApp.Quit();
                    powerPointApp = null;
                }
                
                if (powerPointProc != null)
                {
                    powerPointProc.Kill();
                    powerPointProc.Close();
                    powerPointProc.Dispose();
                    powerPointProc = null;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="docBinary"></param>
        /// <param name="docType"></param>
        /// <param name="outputType"></param>
        /// <returns></returns>
        private byte[] RenderWordDocument(byte[] docBinary, DocumentType docType, OutputFormatType outputType)
        {
            throw new NotImplementedException();
        }
    }
}
