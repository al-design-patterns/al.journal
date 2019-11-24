table 50014 "Ex. Journal Batch"
{
    Caption = 'Ex. Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageID = "Example Jnl. Batches";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Ex. Journal Template";
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(4; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";

            trigger OnValidate();
            begin
                if "Reason Code" <> xRec."Reason Code" then begin
                    ExJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    ExJnlLine.SetRange("Journal Batch Name", Name);
                    ExJnlLine.MODifYALL("Reason Code", "Reason Code");
                    MODifY;
                end;
            end;
        }
        field(5; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";

            trigger OnValidate();
            begin
                if "No. Series" <> '' then begin
                    ExJnlTemplate.Get("Journal Template Name");
                    if ExJnlTemplate.Recurring then
                        Error(
                          OnlyInRecurringJnlErr,
                          FIELDCAPTION("Posting No. Series"));
                    if "No. Series" = "Posting No. Series" then
                        Validate("Posting No. Series", '');
                end;
            end;
        }
        field(6; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnValidate();
            begin
                if ("Posting No. Series" = "No. Series") AND ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(MustBeErr, "Posting No. Series"));
                ExJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                ExJnlLine.SetRange("Journal Batch Name", Name);
                ExJnlLine.MODifYALL("Posting No. Series", "Posting No. Series");
                MODifY;
            end;
        }
        field(22; Recurring; Boolean)
        {
            CalcFormula = Lookup ("Ex. Journal Template".Recurring WHERE(Name = FIELD("Journal Template Name")));
            Caption = 'Recurring';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        ExJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        ExJnlLine.SetRange("Journal Batch Name", Name);
        ExJnlLine.DeleteAll(true);
    end;

    trigger OnInsert();
    begin
        LOCKTABLE;
        ExJnlTemplate.Get("Journal Template Name");
    end;

    trigger OnRename();
    begin
        ExJnlLine.SetRange("Journal Template Name", xRec."Journal Template Name");
        ExJnlLine.SetRange("Journal Batch Name", xRec.Name);
        WHILE ExJnlLine.FINDFIRST DO
            ExJnlLine.RENAME("Journal Template Name", Name, ExJnlLine."Line No.");
    end;

    var
        ExJnlTemplate: Record "Ex. Journal Template";
        ExJnlLine: Record "Ex. Journal Line";
        OnlyInRecurringJnlErr: Label 'Only the %1 field can be filled in on recurring journals.';
        MustBeErr: Label 'must not be %1';

    procedure SetupNewBatch();
    begin
        ExJnlTemplate.Get("Journal Template Name");
        "No. Series" := ExJnlTemplate."No. Series";
        "Posting No. Series" := ExJnlTemplate."Posting No. Series";
        "Reason Code" := ExJnlTemplate."Reason Code";
    end;
}

