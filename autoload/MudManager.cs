using Godot;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using VDS.RDF;
using VDS.RDF.Writing;
using VDS.RDF.Parsing;

public class MudManager : Node
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    public void SendToServer()
    {

    }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        try{
            var g = new TripleStore();
            g.LoadFromUri(new Uri("http://localhost:5000/world/"));
            // g.LoadFromFile("user://savegame.save");

            foreach (Triple t in g.Triples)
            {
                // GD.Print(t.ToString());
            }
        }
        catch (WebException e) {
            GD.Print("WebException");
            GD.Print(e.Message);
        }
        catch (RdfParseException parseEx) 
        {
            //This indicates a parser error e.g unexpected character, premature end of input, invalid syntax etc.
            GD.Print("Parser Error");
            GD.Print(parseEx.Message);
        } 
        catch (RdfException rdfEx)
        {
            //This represents a RDF error e.g. illegal triple for the given syntax, undefined namespace
            GD.Print("RDF Error");
            GD.Print(rdfEx.Message);
        }
        catch(Exception e) {
            GD.Print("Exception");
            GD.Print(e.Message);
        }
    }

    // start with local saving/loading then
    // start with just outputting the inhabitants to a storage, and reading it back (Linked Data)
}
