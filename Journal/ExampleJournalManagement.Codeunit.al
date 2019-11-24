codeunit 50011 ExJnlManagement
{
    trigger OnRun();
    begin
    end;

    var
        OpenFromBatch: Boolean;
        ExamplesTxt: Label 'EXAMPLES';
        ExampleJournalsTxt: Label 'Example Journals';
        RecurringTxt: Label 'RECURRING';
        RecurringExampleJournalTxt: Label 'Recurring Example Journal';
        DefaultTxt: Label 'DEFAULT';
        DefaultJournalTxt: Label 'Default Journal';

    procedure TemplateSelection(PageID: Integer; RecurringJnl: Boolean; var ExJnlLine: Record "Ex. Journal Line"; var JnlSelected: Boolean);
    var
        ExJnlTemplate: Record "Ex. Journal Template";
    begin
        JnlSelected := true;

        ExJnlTemplate.Reset;
        ExJnlTemplate.SetRange("Page ID", PageID);
        ExJnlTemplate.SetRange(Recurring, RecurringJnl);

        CASE ExJnlTemplate.COUNT of
            0:
                begin
                    ExJnlTemplate.INIT;
                    ExJnlTemplate.Recurring := RecurringJnl;
                    if NOT RecurringJnl then begin
                        ExJnlTemplate.Name := ExamplesTxt;
                        ExJnlTemplate.Description := ExampleJournalsTxt;
                    end else begin
                        ExJnlTemplate.Name := RecurringTxt;
                        ExJnlTemplate.Description := RecurringExampleJournalTxt;
                    end;
                    ExJnlTemplate.Validate("Page ID");
                    ExJnlTemplate.Insert;
                    Commit;
                end;
            1:
                ExJnlTemplate.FindFirst;
            else
                JnlSelected := PAGE.RunMODAL(0, ExJnlTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            ExJnlLine.FilterGroup := 2;
            ExJnlLine.SetRange("Journal Template Name", ExJnlTemplate.Name);
            ExJnlLine.FilterGroup := 0;
            if OpenFromBatch then begin
                ExJnlLine."Journal Template Name" := '';
                Page.Run(ExJnlTemplate."Page ID", ExJnlLine);
            end;
        end;
    end;

    procedure TemplateSelectionFromBatch(var ExJnlBatch: Record "Ex. Journal Batch");
    var
        ExJnlLine: Record "Ex. Journal Line";
        ExJnlTemplate: Record "Ex. Journal Template";
    begin
        OpenFromBatch := true;
        ExJnlTemplate.Get(ExJnlBatch."Journal Template Name");
        ExJnlTemplate.TestField("Page ID");
        ExJnlBatch.TestField(Name);

        ExJnlLine.FILTERGROUP := 2;
        ExJnlLine.SetRange("Journal Template Name", ExJnlTemplate.Name);
        ExJnlLine.FILTERGROUP := 0;

        ExJnlLine."Journal Template Name" := '';
        ExJnlLine."Journal Batch Name" := ExJnlBatch.Name;
        PAGE.Run(ExJnlTemplate."Page ID", ExJnlLine);
    end;

    procedure OpenJnl(var CurrentJnlBatchName: Code[10]; var ExJnlLine: Record 50013);
    begin
        CheckTemplateName(ExJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        ExJnlLine.FILTERGROUP := 2;
        ExJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        ExJnlLine.FILTERGROUP := 0;
    end;

    procedure OpenJnlBatch(var ExJnlBatch: Record "Ex. Journal Batch");
    var
        ExJnlTemplate: Record 50012;
        ExJnlLine: Record 50013;
        JnlSelected: Boolean;
    begin
        if ExJnlBatch.GetFilter("Journal Template Name") <> '' then
            exit;
        ExJnlBatch.FILTERGROUP(2);
        if ExJnlBatch.GetFilter("Journal Template Name") <> '' then begin
            ExJnlBatch.FILTERGROUP(0);
            exit;
        end;
        ExJnlBatch.FILTERGROUP(0);

        if NOT ExJnlBatch.FIND('-') then begin
            if NOT ExJnlTemplate.FINDFIRST then
                TemplateSelection(0, FALSE, ExJnlLine, JnlSelected);
            if ExJnlTemplate.FINDFIRST then
                CheckTemplateName(ExJnlTemplate.Name, ExJnlBatch.Name);
            ExJnlTemplate.SetRange(Recurring, true);
            if NOT ExJnlTemplate.FINDFIRST then
                TemplateSelection(0, true, ExJnlLine, JnlSelected);
            if ExJnlTemplate.FINDFIRST then
                CheckTemplateName(ExJnlTemplate.Name, ExJnlBatch.Name);
            ExJnlTemplate.SetRange(Recurring);
        end;
        ExJnlBatch.FIND('-');
        JnlSelected := true;
        ExJnlBatch.CALCFIELDS(Recurring);
        ExJnlTemplate.SetRange(Recurring, ExJnlBatch.Recurring);
        if ExJnlBatch.GetFilter("Journal Template Name") <> '' then
            ExJnlTemplate.SetRange(Name, ExJnlBatch.GetFilter("Journal Template Name"));
        CASE ExJnlTemplate.COUNT of
            1:
                ExJnlTemplate.FINDFIRST;
            else
                JnlSelected := PAGE.RunMODAL(0, ExJnlTemplate) = ACTION::LookupOK;
        end;
        if NOT JnlSelected then
            Error('');

        ExJnlBatch.FILTERGROUP(2);
        ExJnlBatch.SetRange("Journal Template Name", ExJnlTemplate.Name);
        ExJnlBatch.FILTERGROUP(0);
    end;

    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10]);
    var
        ExJnlBatch: Record 50014;
    begin
        ExJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if NOT ExJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName) then begin
            if NOT ExJnlBatch.FINDFIRST then begin
                ExJnlBatch.INIT;
                ExJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
                ExJnlBatch.SetupNewBatch;
                ExJnlBatch.Name := DefaultTxt;
                ExJnlBatch.Description := DefaultJournalTxt;
                ExJnlBatch.INSERT(true);
                COMMIT;
            end;
            CurrentJnlBatchName := ExJnlBatch.Name;
        end;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10]; var ExJnlLine: Record "Ex. Journal Line");
    var
        ExJnlBatch: Record 50014;
    begin
        ExJnlBatch.Get(ExJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
    end;

    procedure SetName(CurrentJnlBatchName: Code[10]; var ExJnlLine: Record "Ex. Journal Line");
    begin
        ExJnlLine.FILTERGROUP := 2;
        ExJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        ExJnlLine.FILTERGROUP := 0;
        if ExJnlLine.FIND('-') then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10]; var ExJnlLine: Record "Ex. Journal Line"): Boolean;
    var
        ExJnlBatch: Record "Ex. Journal Batch";
    begin
        COMMIT;
        ExJnlBatch."Journal Template Name" := ExJnlLine.GetRangeMax("Journal Template Name");
        ExJnlBatch.Name := ExJnlLine.GetRangeMax("Journal Batch Name");
        ExJnlBatch.FILTERGROUP(2);
        ExJnlBatch.SetRange("Journal Template Name", ExJnlBatch."Journal Template Name");
        ExJnlBatch.FILTERGROUP(0);
        if PAGE.RunMODAL(0, ExJnlBatch) = ACTION::LookupOK then begin
            CurrentJnlBatchName := ExJnlBatch.Name;
            SetName(CurrentJnlBatchName, ExJnlLine);
        end;
    end;
}

