codeunit 50017 "Ex. Jnl.-Post+Print"
{
    TableNo = "Ex. Journal Line";

    trigger OnRun();
    begin
        ExJnlLine.COPY(Rec);
        Code;
        COPY(ExJnlLine);
    end;

    var
        ExJnlTemplate: Record "Ex. Journal Template";
        ExJnlLine: Record "Ex. Journal Line";
        ExReg: Record "Example Register";
        ExJnlPostBatch: Codeunit "Ex. Jnl.-Post Batch";
        TempJnlBatchName: Code[10];
        NoFilterIfRecurringErr: Label 'cannot be filtered when posting recurring journals';
        PostAndPrintJnlQst: Label 'Do you want to post the journal lines and print the posting report?';
        NothingToPostErr: Label 'There is nothing to post.';
        JournalSuccessPostMsg: Label 'The journal lines were successfully posted.';
        JnlSuccessPostMsg: Label 'The journal lines were successfully posted. ';
        YouAreInJnlMsg: Label 'You are now in the %1 journal.';

    local procedure "Code"();
    begin
        WITH ExJnlLine DO begin
            ExJnlTemplate.Get("Journal Template Name");
            ExJnlTemplate.TestField("Posting Report ID");
            if ExJnlTemplate.Recurring AND (GetFilter("Posting Date") <> '') then
                FieldError("Posting Date", NoFilterIfRecurringErr);

            if NOT CONFIRM(PostAndPrintJnlQst) then
                exit;

            TempJnlBatchName := "Journal Batch Name";

            ExJnlPostBatch.Run(ExJnlLine);

            if ExReg.Get("Line No.") then begin
                ExReg.SETRECFILTER;
                REPORT.Run(ExJnlTemplate."Posting Report ID", FALSE, FALSE, ExReg);
            end;

            if "Line No." = 0 then
                MESSAGE(NothingToPostErr)
            else
                if TempJnlBatchName = "Journal Batch Name" then
                    MESSAGE(JournalSuccessPostMsg)
                else
                    MESSAGE(
                      JnlSuccessPostMsg +
                      YouAreInJnlMsg,
                      "Journal Batch Name");

            if NOT FIND('=><') OR (TempJnlBatchName <> "Journal Batch Name") then begin
                RESET;
                FILTERGROUP(2);
                SetRange("Journal Template Name", "Journal Template Name");
                SetRange("Journal Batch Name", "Journal Batch Name");
                FILTERGROUP(0);
                "Line No." := 1;
            end;
        end;
    end;
}

