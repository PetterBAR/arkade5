using System;
using System.Xml;
using Arkivverket.Arkade.Core;

namespace Arkivverket.Arkade.Tests.Noark5
{
    public class NumberOfArchiveParts : BaseTest
    {

        protected override void Test(ArchiveExtraction archive)
        {
            using (var reader = XmlReader.Create(archive.GetDescriptionFileName()))
            {
                int counter = 0;
                if (reader.ReadToDescendant("arkivdel"))
                {
                    counter++;
                    while (reader.ReadToNextSibling("arkivdel"))
                    {
                        counter++;
                    }
                }
                Console.WriteLine("Number of archiveparts: " + counter);
            }
        }
    }
}
