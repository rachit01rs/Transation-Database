CREATE PROC [dbo].[spa_mdx_config]

(

	@flag					CHAR(1),

	@app_user				VARCHAR(20)	 = NULL,

	@sno					INT			 = NULL,

	@bank_id				INT			 = NULL,

	@merchant_id			INT			 = NULL,

	@password				VARCHAR(50)  = NULL,	

	@user_name				VARCHAR(20)  = NULL,

	@signature_id			VARCHAR(20)  = NULL,	

	@http_url				VARCHAR(100) = NULL,

	@soap_url				VARCHAR(100) = NULL,

	@settle_ho_account		VARCHAR(20)  = NULL,

	@settle_payable_account	VARCHAR(20)	 = NULL,

	@ho_comm_type			CHAR(1)		 = NULL

)

AS

BEGIN

	IF @flag = 's'		--select

	BEGIN

		SELECT 

				--ISNULL(mc.sno,'') sno,

			 --  ISNULL(mc.bank_id,'') bank_id,

			 --  ISNULL(mc.merchant_id,'') merchant_id,

			 --  ISNULL(mc.user_name,'') user_name,

			 --  ISNULL(mc.signature_id,'') signature_id,

			 --  ISNULL(mc.http_url,'') http_url,

			 --  ISNULL(mc.soap_url,'') soap_url

			 *   FROM mdx_config mc

	END

	

	IF @flag = 'i'		--insert new configuration

	BEGIN

		IF EXISTS(SELECT 'X' FROM mdx_config)

		BEGIN

			SELECT '101' STATUS_CODE, 'Configuration already exists' msg

			RETURN

		END

		

		BEGIN

			INSERT INTO mdx_config(bank_id,merchant_id,[user_name],[password],signature_id,http_url,soap_url,

			created_by,created_ts,settle_ho_account,settle_payable_account,ho_comm_type)

			VALUES(@bank_id,@merchant_id,@user_name,@password,@signature_id,@http_url,@soap_url,@app_user,GETDATE(),

			@settle_ho_account,@settle_payable_account,@ho_comm_type)

			

			SELECT '0' STATUS_CODE,'MDX successfully configured' msg	

		END

		

		

	END

	IF @flag = 'u'		--update configuration

	BEGIN

		IF NOT EXISTS(SELECT 'X' FROM mdx_config)

		BEGIN

			SELECT '101' STATUS_CODE, 'No Configuration exists' msg

			RETURN

		END

		

		BEGIN

			UPDATE mdx_config SET

				bank_id = @bank_id,

				merchant_id = @merchant_id,

				[user_name] = @user_name,

				[password] = @password,

				signature_id = @signature_id,

				http_url = @http_url,

				soap_url = @soap_url,

				updated_by = @app_user,

				updated_ts = GETDATE(),

				settle_ho_account = @settle_ho_account,

				settle_payable_account = @settle_payable_account,

				ho_comm_type = @ho_comm_type

			WHERE sno=@sno

			

			SELECT '0' STATUS_CODE,'MDX Configuration successfully updated.' msg

		END

	END

END
