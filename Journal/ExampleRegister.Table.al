table 50015 "Example Register"
{
    Caption = 'Example Register';
    DrillDownPageID = "Example Registers";
    LookupPageID = "Example Registers";

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'No.';
        }
        field(2; "From Entry No."; Integer)
        {
            Caption = 'From Entry No.';
        }
        field(3; "To Entry No."; Integer)
        {
            Caption = 'To Entry No.';
        }
        field(4; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
        }
        field(5; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(6; "User ID"; Code[50])
        {
            Caption = 'User ID';

            trigger OnLookup();
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.DisplayUserInformation("User ID");
            end;
        }
        field(7; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Creation Date")
        {
        }
        key(Key3; "Source Code", "Journal Batch Name", "Creation Date")
        {
        }
    }
}

