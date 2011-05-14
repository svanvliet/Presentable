using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace DocumentConversionService
{
    /// <summary>
    /// 
    /// </summary>
    [ServiceContract(Name = "DocumentConversionService", Namespace = "http://schemas.tenseventynine.com/")]
    public interface IDocumentConverter
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="docBinary"></param>
        /// <param name="fileNameWithExt"></param>
        /// <returns></returns>
        [OperationContract]
        byte[] RenderAsPdf(byte[] docBinary, string fileNameWithExt);
    }
}
