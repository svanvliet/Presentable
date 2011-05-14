<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebClient.aspx.cs" Inherits="TSN.Presentable.Services.WebClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <h2>Convert PowerPoint to PDF</h2>
    </div>
    <div>
        <table>
            <tr>
                <td>Select PPT(X):</td>
                <td><asp:FileUpload runat="server" ID="documentFileBrowse" /></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td><asp:Button Text="Convert File" runat="server" ID="submitButton" 
                        onclick="submitButton_Click" /></td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
