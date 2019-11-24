codeunit 50015 "Ex. Jnl.-B.Post"
{
    TableNo = "Ex. Journal Batch";

    trigger OnRun();
    begin
        ExJnlBatch.COPY(Rec);
        Code;
        Rec := ExJnlBatch;
    end;

    var
        ExJnlTemplate: Record "Ex. Journal Template";
        ExJnlBatch: Record "Ex. Journal Batch";
        ExJnlLine: Record "Ex. Journal Line";
        ExJnlPostBatch: Codeunit "Ex. Jnl.-Post Batch";
        JnlWithErrors: Boolean;
        PostTheJournalsQst: Label 'Do you want to post the journals?';
        PostingSuccessMsg: Label 'The journals were successfully posted.';
        NotPossibleMsg: Label 'It was not possible to post all of the journals. ';
        NotSuccessMsg: Label 'The journals that were not successfully posted are now marked.';

    local procedure "Code"();
    begin
        WITH ExJnlBatch DO begin
            ExJnlTemplate.Get("Journal Template Name");
            ExJnlTemplate.TestField("Force Posting Report", FALSE);

            if NOT CONFIRM(PostTheJournalsQst) then
                exit;

            FIND('-');
            REPEAT
                ExJnlLine."Journal Template Name" := "Journal Template Name";
                ExJnlLine."Journal Batch Name" := Name;
                ExJnlLine."Line No." := 1;
                Clear(ExJnlPostBatch);
                if ExJnlPostBatch.Run(ExJnlLine) then
                    MARK(FALSE)
                else begin
                    MARK(true);
                    JnlWithErrors := true;
                end;
            UNTIL NEXT = 0;

            if NOT JnlWithErrors then
                MESSAGE(PostingSuccessMsg)
            else
                MESSAGE(
                  NotPossibleMsg +
                  NotSuccessMsg);

            if NOT FIND('=><') then begin
                RESET;
                FILTERGROUP(2);
                SetRange("Journal Template Name", "Journal Template Name");
                FILTERGROUP(0);
                Name := '';
            end;
        end;
    end;
}

