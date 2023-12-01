ALTER PROCEDURE [dbo].[Cashier_AppPayment]
	@custnum varchar(20),
	@cname varchar(100),
	@pymntmode varchar(10),
	@pymnttype varchar(10),
	@payamnt money,
	@subtot1 money,
	@subtot2 money,	
	@pymntdtl varchar(100),
	@ornum varchar(50),
	@rcvdby varchar(50),
	@subtot3 money = 0,
	@noncustomerdiscount money = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if(@subtot2 > 0)
	begin
		set @subtot2 = isnull(@subtot2,0) - isnull(@noncustomerdiscount,0)
	end
	else
	begin
		set @subtot1 = isnull(@subtot1,0) - isnull(@noncustomerdiscount,0)
	end

	insert cpaym2(custnum,cname,pymntmode2,pymnttyp,pymntstat,payamnt,subtot1,subtot2,paydate,pymntdtl,ornum,rcvdby,pymntmode,subtot3,tax8,CreatedDate)
		   values(@custnum,@cname,@pymntmode,@pymnttype,1,@payamnt,case when @subtot1 <= @payamnt then @subtot1
		   else @payamnt end,@subtot2,convert(varchar(10),getdate(),111),@pymntdtl,@ornum,@rcvdby,@pymntmode,@subtot3,@noncustomerdiscount,GETDATE())

		   update [Application_OtherFees]
		   set Ornum = @ornum
		   where Applnum = @custnum

END

GO


