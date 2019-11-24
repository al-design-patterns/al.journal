tableextension 50011 "Example Source Code Setup" extends "Source Code Setup"
{
    fields
    {
        field(50011; "Example Journal"; Code[10])
        {
            TableRelation = "Source Code";
        }
    }
}