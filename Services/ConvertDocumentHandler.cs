using System;
using System.Linq;
using System.Web;

namespace TSN.Presentable.Services
{
    public class ConvertDocumentHandler : IHttpHandler
    {
        /// <summary>
        /// You will need to configure this handler in the web.config file of your 
        /// web and register it with IIS before being able to use it. For more information
        /// see the following link: http://go.microsoft.com/?linkid=8101007
        /// </summary>
        #region IHttpHandler Members

        public bool IsReusable
        {
            // Return false in case your Managed Handler cannot be reused for another request.
            // Usually this would be false in case you have some state information preserved per request.
            get { return true; }
        }

        public void ProcessRequest(HttpContext context)
        {
            if (context.Request.HttpMethod.Equals("POST", StringComparison.InvariantCultureIgnoreCase))
            {
                string documentID = context.Request.Params["documentID"];
                if (String.IsNullOrEmpty(documentID))
                {
                    throw new ArgumentNullException("documentID", "A required POST parameter was missing.");
                }

                HttpPostedFile document = context.Request.Files["document"];
                if (document == default(HttpPostedFile))
                {
                    throw new ArgumentNullException("document", "A required POST parameter was missing.");
                }

                string fileNameWithExt = document.FileName;
                byte[] docBinary = new byte[document.ContentLength];
                document.InputStream.Read(docBinary, 0, document.ContentLength);

                DocumentConverter converter = new DocumentConverter();
                byte[] convertedDoc = converter.RenderAsPdf(docBinary, fileNameWithExt);

                context.Response.Headers.Add("documentID", documentID);

                context.Response.ContentType = "application/pdf";
                context.Response.BinaryWrite(convertedDoc);
                context.Response.End();
            }
            else
            {
                context.Response.Write("<html><head><title>Invalid Request</title></head>");
                context.Response.Write("<body>The URI you have requested does not support this HTTP method.</body></html>");
                context.Response.End();
            }
            //write your handler implementation here.
        }

        #endregion
    }
}
