using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TSN.Presentable.Services
{
    public partial class WebClient : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void submitButton_Click(object sender, EventArgs e)
        {
            var docConverter = new DocumentConverterServiceReference.DocumentConverter();

            var pdfBinary = docConverter.RenderAsPdf(documentFileBrowse.FileBytes, documentFileBrowse.FileName);

            Response.ContentType = "application/pdf";
            Response.BinaryWrite(pdfBinary);
            Response.End();
        }
    }
}