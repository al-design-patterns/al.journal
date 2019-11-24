table 50012 "Ex. Journal Template"
{
    Caption = 'Ex. Journal Template';
    DrillDownPageID = 50015;
    LookupPageID = 50015;

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(5; "Test Report ID"; Integer)
        {
            Caption = 'Test Report ID';
        }
        field(6; "Page ID"; Integer)
        {
            Caption = 'Page ID';

            trigger OnValidate();
            begin
                if "Page ID" = 0 then
                    Validate(Recurring);
            end;
        }
        field(7; "Posting Report ID"; Integer)
        {
            Caption = 'Posting Report ID';
        }
        field(8; "Force Posting Report"; Boolean)
        {
            Caption = 'Force Posting Report';
        }
        field(10; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";

            trigger OnValidate();
            begin
                ExJnlLine.SetRange("Journal Template Name", Name);
                ExJnlLine.MODifYALL("Source Code", "Source Code");
                Modify;
            end;
        }
        field(11; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(12; Recurring; Boolean)
        {
            Caption = 'Recurring';

            trigger OnValidate();
            begin
                "Page ID" := PAGE::"Example Journal";
                "Posting Report ID" := REPORT::"Example Register";
                SourceCodeSetup.Get;
                "Source Code" := SourceCodeSetup."Example Journal";
                if Recurring then
                    TestField("No. Series", '');
            end;
        }
        field(13; "Test Report Caption"; Text[250])
        {
            Caption = 'Test Report Caption';
            Editable = false;
        }
        field(14; "Page Caption"; Text[250])
        {
            Caption = 'Page Caption';
            Editable = false;
        }
        field(15; "Posting Report Caption"; Text[250])
        {
            Caption = 'Posting Report Caption';
            Editable = false;
        }
        field(16; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";

            trigger OnValidate();
            begin
                if "No. Series" <> '' then begin
                    if Recurring then
                        Error(
                          OnlyRecurringErr,
                          FIELDCAPTION("Posting No. Series"));
                    if "No. Series" = "Posting No. Series" then
                        "Posting No. Series" := '';
                end;
            end;
        }
        field(17; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnValidate();
            begin
                if ("Posting No. Series" = "No. Series") AND ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(MustBeErr, "Posting No. Series"));
            end;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        ExJnlLine.SetRange("Journal Template Name", Name);
        ExJnlLine.DeleteAll(true);
        ExJnlBatch.SetRange("Journal Template Name", Name);
        ExJnlBatch.DeleteAll;
    end;

    trigger OnInsert();
    begin
        Validate("Page ID");
    end;

    var
        ExJnlBatch: Record "Ex. Journal Batch";
        ExJnlLine: Record "Ex. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        OnlyRecurringErr: Label 'Only the %1 field can be filled in on recurring journals.';
        MustBeErr: Label 'must not be %1';
}

