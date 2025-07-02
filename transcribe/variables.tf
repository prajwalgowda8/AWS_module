
variable "service_name" {
  description = "Name of the service using Transcribe"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for audio files"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for audio files"
  type        = string
}

variable "language_code" {
  description = "Language code for transcription"
  type        = string
  default     = "en-US"
  validation {
    condition = contains([
      "en-US", "en-GB", "en-AU", "en-IN", "es-US", "es-ES", "fr-FR", "fr-CA",
      "de-DE", "it-IT", "pt-BR", "ja-JP", "ko-KR", "zh-CN", "ar-SA", "hi-IN",
      "nl-NL", "ru-RU", "sv-SE", "da-DK", "no-NO", "fi-FI", "pl-PL", "tr-TR"
    ], var.language_code)
    error_message = "Language code must be a supported AWS Transcribe language."
  }
}

# CloudWatch Logging Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "log_kms_key_id" {
  description = "KMS key ID for CloudWatch log encryption"
  type        = string
  default     = null
}

# Custom Vocabulary Configuration
variable "create_custom_vocabulary" {
  description = "Create a custom vocabulary for improved transcription accuracy"
  type        = bool
  default     = false
}

variable "vocabulary_file_uri" {
  description = "S3 URI of the vocabulary file"
  type        = string
  default     = null
}

variable "vocabulary_phrases" {
  description = "List of phrases for custom vocabulary"
  type        = list(string)
  default     = []
}

# Language Model Configuration
variable "create_language_model" {
  description = "Create a custom language model"
  type        = bool
  default     = false
}

variable "base_model_name" {
  description = "Base model name for custom language model"
  type        = string
  default     = "NarrowBand"
  validation {
    condition     = contains(["NarrowBand", "WideBand"], var.base_model_name)
    error_message = "Base model name must be either NarrowBand or WideBand."
  }
}

variable "language_model_data_s3_uri" {
  description = "S3 URI of the language model training data"
  type        = string
  default     = null
}

variable "tuning_data_s3_uri" {
  description = "S3 URI of the tuning data for language model"
  type        = string
  default     = null
}

# S3 Notification Configuration
variable "enable_s3_notifications" {
  description = "Enable S3 bucket notifications for automatic transcription"
  type        = bool
  default     = false
}

variable "lambda_function_arn" {
  description = "ARN of Lambda function to trigger on S3 events"
  type        = string
  default     = null
}

variable "sqs_queue_arn" {
  description = "ARN of SQS queue to send S3 notifications"
  type        = string
  default     = null
}

variable "s3_notification_events" {
  description = "S3 events that trigger notifications"
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
}

variable "s3_notification_filter_prefix" {
  description = "S3 object key prefix filter for notifications"
  type        = string
  default     = "audio/"
}

variable "s3_notification_filter_suffix" {
  description = "S3 object key suffix filter for notifications"
  type        = string
  default     = ".mp3"
}

# Lambda Trigger Role Configuration
variable "create_lambda_trigger_role" {
  description = "Create IAM role for Lambda function to trigger transcription jobs"
  type        = bool
  default     = false
}

# Transcription Job Configuration
variable "media_format" {
  description = "Format of the input media file"
  type        = string
  default     = "mp3"
  validation {
    condition     = contains(["mp3", "mp4", "wav", "flac", "ogg", "amr", "webm"], var.media_format)
    error_message = "Media format must be one of: mp3, mp4, wav, flac, ogg, amr, webm."
  }
}

variable "media_sample_rate_hertz" {
  description = "Sample rate of the input media in Hertz"
  type        = number
  default     = null
  validation {
    condition = var.media_sample_rate_hertz == null || (
      var.media_sample_rate_hertz >= 8000 && var.media_sample_rate_hertz <= 48000
    )
    error_message = "Media sample rate must be between 8000 and 48000 Hz."
  }
}

variable "channel_identification" {
  description = "Enable channel identification for multi-channel audio"
  type        = bool
  default     = false
}

variable "show_speaker_labels" {
  description = "Enable speaker identification in transcription"
  type        = bool
  default     = false
}

variable "max_speaker_labels" {
  description = "Maximum number of speakers to identify"
  type        = number
  default     = 2
  validation {
    condition     = var.max_speaker_labels >= 2 && var.max_speaker_labels <= 10
    error_message = "Maximum speaker labels must be between 2 and 10."
  }
}

variable "output_bucket_name" {
  description = "S3 bucket name for transcription output (if different from input bucket)"
  type        = string
  default     = null
}

variable "output_key_prefix" {
  description = "S3 key prefix for transcription output files"
  type        = string
  default     = "transcriptions/"
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all Transcribe resources"
  type        = map(string)
  validation {
    condition = alltrue([
      contains(keys(var.mandatory_tags), "Environment"),
      contains(keys(var.mandatory_tags), "Project"),
      contains(keys(var.mandatory_tags), "Owner")
    ])
    error_message = "Mandatory tags must include Environment, Project, and Owner."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to all Transcribe resources"
  type        = map(string)
  default     = {}
}
