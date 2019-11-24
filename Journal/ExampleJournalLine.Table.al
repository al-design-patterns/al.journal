table 50013 "Ex. Journal Line"
{
    Caption = 'Ex. Journal Line';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Ex. Journal Template";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Usage,Sale';
            OptionMembers = Usage,Sale;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate();
            begin
                Validate("Document Date", "Posting Date");
            end;
        }
        field(8; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(18; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(19; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(21; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(23; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Ex. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(24; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(25; "Recurring Method"; Option)
        {
            BlankZero = true;
            Caption = 'Recurring Method';
            OptionCaption = ',Fixed,Variable';
            OptionMembers = ,"Fixed",Variable;
        }
        field(26; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(27; "Recurring Frequency"; DateFormula)
        {
            Caption = 'Recurring Frequency';
        }
        field(28; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(29; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(30; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(31; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(32; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDimensions;
            end;
        }
        field(959; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert();
    begin
        LockTable;
        ExJnlTemplate.Get("Journal Template Name");
        ExJnlBatch.Get("Journal Template Name", "Journal Batch Name");

        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    var
        ExJnlTemplate: Record "Ex. Journal Template";
        ExJnlBatch: Record "Ex. Journal Batch";
        ExJnlLine: Record "Ex. Journal Line";
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        GLSetupRead: Boolean;

    procedure EmptyLine(): Boolean;
    begin  // To Do - Event Publisher for implementation
        exit(Quantity = 0);
    end;

    procedure SetUpNewLine(LastExJnlLine: Record 50013);
    begin
        ExJnlTemplate.Get("Journal Template Name");
        ExJnlBatch.Get("Journal Template Name", "Journal Batch Name");
        ExJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        ExJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if ExJnlLine.FINDFIRST then begin
            "Posting Date" := LastExJnlLine."Posting Date";
            "Document Date" := LastExJnlLine."Posting Date";
            "Document No." := LastExJnlLine."Document No.";
        end else begin
            "Posting Date" := WORKDATE;
            "Document Date" := WORKDATE;
            if ExJnlBatch."No. Series" <> '' then begin
                Clear(NoSeriesMgt);
                "Document No." := NoSeriesMgt.TryGetNextNo(ExJnlBatch."No. Series", "Posting Date");
            end;
        end;
        "Recurring Method" := LastExJnlLine."Recurring Method";
        "Source Code" := ExJnlTemplate."Source Code";
        "Reason Code" := ExJnlBatch."Reason Code";
        "Posting No. Series" := ExJnlBatch."Posting No. Series";
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]);
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        TableID[1] := Type1;
        No[1] := No1;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(TableID, No, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20]);
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    local procedure GetGLSetup();
    begin
        if NOT GLSetupRead then
            GLSetup.Get;
        GLSetupRead := true;
    end;

    procedure ShowDimensions();
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', "Journal Template Name", "Journal Batch Name", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure PostSingle();
    var
        ExampleJnlPostLine: Codeunit "Ex. Jnl.-Post Line";
    begin
        ExampleJnlPostLine.Run(Rec);
    end;
}

