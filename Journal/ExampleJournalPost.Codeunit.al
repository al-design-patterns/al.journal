codeunit 50013 "Ex. Jnl.-Post"
{
    TableNo = 50013;

    trigger OnRun();
    begin
        ExJnlLine.COPY(Rec);
        Code;
        COPY(ExJnlLine);
    end;

    var

        ExJnlTemplate: Record "Ex. Journal Template";
        ExJnlLine: Record "Ex. Journal Line";
        ExJnlPostBatch: Codeunit "Ex. Jnl.-Post Batch";
        TempJnlBatchName: Code[10];
        CannotBeFiteredErr: Label 'cannot be filtered when posting recurring journals';
        PostJournalQst: Label 'Do you want to post the journal lines?';
        NothingToPostErr: Label 'There is nothing to post.';
        LinesSuccessMsg: Label 'The journal lines were successfully posted.';
        LineSuccessMsg: Label 'The journal lines were successfully posted. ';
        YouAreInMsg: Label 'You are now in the %1 journal.';

    local procedure "Code"();
    begin
        WITH ExJnlLine DO begin
            ExJnlTemplate.Get("Journal Template Name");
            ExJnlTemplate.TestField("Force Posting Report", FALSE);
            if ExJnlTemplate.Recurring AND (GetFilter("Posting Date") <> '') then
                FieldError("Posting Date", CannotBeFiteredErr);

            if NOT CONFIRM(PostJournalQst) then
                exit;

            TempJnlBatchName := "Journal Batch Name";

            ExJnlPostBatch.Run(ExJnlLine);

            if "Line No." = 0 then
                MESSAGE(NothingToPostErr)
            else
                if TempJnlBatchName = "Journal Batch Name" then
                    MESSAGE(LinesSuccessMsg)
                else
                    MESSAGE(
                      LineSuccessMsg +
                      YouAreInMsg,
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

