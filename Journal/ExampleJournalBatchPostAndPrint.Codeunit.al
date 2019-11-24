codeunit 50016 "Ex. Jnl.-B.Post+Print"
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
        ExReg: Record "Example Register";
        ExJnlPostBatch: Codeunit "Ex. Jnl.-Post Batch";
        JnlWithErrors: Boolean;
        PostAndPrintQst: Label 'Do you want to post the journals and print the posting report?';
        SuccessMsg: Label 'The journals were successfully posted.';
        NotPossibleErr: Label 'It was not possible to post all of the journals. ';
        NotSuccessMsg: Label 'The journals that were not successfully posted are now marked.';

    local procedure "Code"();
    begin
        WITH ExJnlBatch DO begin
            ExJnlTemplate.Get("Journal Template Name");
            ExJnlTemplate.TestField("Posting Report ID");

            if NOT CONFIRM(PostAndPrintQst) then
                exit;

            FIND('-');
            REPEAT
                ExJnlLine."Journal Template Name" := "Journal Template Name";
                ExJnlLine."Journal Batch Name" := Name;
                ExJnlLine."Line No." := 1;
                Clear(ExJnlPostBatch);
                if ExJnlPostBatch.Run(ExJnlLine) then begin
                    MARK(FALSE);
                    if ExReg.Get(ExJnlLine."Line No.") then begin
                        ExReg.SETRECFILTER;
                        REPORT.Run(ExJnlTemplate."Posting Report ID", FALSE, FALSE, ExReg);
                    end;
                end else begin
                    MARK(true);
                    JnlWithErrors := true;
                end;
            UNTIL NEXT = 0;

            if NOT JnlWithErrors then
                MESSAGE(SuccessMsg)
            else
                MESSAGE(
                  NotPossibleErr +
                  NotSuccessMsg);

            if NOT FIND('=><') then begin
                RESET;
                Name := '';
            end;
        end;
    end;
}

