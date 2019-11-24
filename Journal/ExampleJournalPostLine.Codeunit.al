codeunit 50014 "Ex. Jnl.-Post Line"
{
    TableNo = "Ex. Journal Line";

    trigger OnRun();
    begin
        RunWithCheck(Rec);
    end;

    var
        ExReg: Record "Example Register";
        ExJnlCheckLine: Codeunit "Ex. Jnl.-Check Line";
        NextEntryNo: Integer;

    procedure RunWithCheck(var ExJnlLine: Record "Ex. Journal Line");
    begin
        WITH ExJnlLine DO begin
            if EmptyLine then
                exit;

            ExJnlCheckLine.RunCheck(ExJnlLine);

            IsolateTransactionAndGetNextEntryNo(NextEntryNo);

            if "Document Date" = 0D then
                "Document Date" := "Posting Date";

            if ExReg."No." = 0 then begin
                ExReg.LOCKTABLE;
                if (NOT ExReg.FINDLAST) OR (ExReg."To Entry No." <> 0) then begin
                    ExReg.INIT;
                    ExReg."No." := ExReg."No." + 1;
                    ExReg."From Entry No." := NextEntryNo;
                    ExReg."To Entry No." := NextEntryNo;
                    ExReg."Creation Date" := TODAY;
                    ExReg."Source Code" := "Source Code";
                    ExReg."Journal Batch Name" := "Journal Batch Name";
                    ExReg."User ID" := UserId.Substring(1, MaxStrLen(ExReg."User ID"));
                    ExReg.INSERT;
                end;
            end;
            ExReg."To Entry No." := NextEntryNo;
            ExReg.MODifY;

            PostEntry(ExJnlLine, NextEntryNo);

            NextEntryNo := NextEntryNo + 1;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure IsolateTransactionAndGetNextEntryNo(var NextEntryNo: Integer)
    begin
        //* To Do - Event Publisher TransactionIsolation

        // if NextEntryNo = 0 then begin
        //     ExLedgEntry.LOCKTABLE;
        //     if ExLedgEntry.FINDLAST then
        //         NextEntryNo := ExLedgEntry."Entry No.";
        //     NextEntryNo := NextEntryNo + 1;
        // end;
    end;

    [IntegrationEvent(false, false)]
    local procedure PostEntry(var ExJnlLine: Record "Ex. Journal Line"; NextEntryNo: Integer)
    begin
    end;

}

