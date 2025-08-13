package middleware

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/middleware"
	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/middleware/tracing"
	"github.com/go-kratos/kratos/v2/transport"
)

// Logging 日志中间件
func Logging(logger log.Logger) middleware.Middleware {
	return func(handler middleware.Handler) middleware.Handler {
		return func(ctx context.Context, req interface{}) (reply interface{}, err error) {
			var (
				code      int32
				reason    string
				kind      string
				operation string
			)
			startTime := time.Now()
			if tr, ok := transport.FromServerContext(ctx); ok {
				kind = tr.Kind().String()
				operation = tr.Operation()
			}
			reply, err = handler(ctx, req)
			if se := FromError(err); se != nil {
				code = se.Code
				reason = se.Reason
			}
			logger.WithContext(ctx).Log(log.LevelInfo,
				"kind", "server",
				"component", kind,
				"operation", operation,
				"args", extractArgs(req),
				"code", code,
				"reason", reason,
				"stack", extractStack(err),
				"latency", time.Since(startTime).Seconds(),
			)
			return
		}
	}
}

// Recovery 恢复中间件
func Recovery() middleware.Middleware {
	return recovery.Recovery()
}

// Tracing 链路追踪中间件
func Tracing() middleware.Middleware {
	return tracing.Server()
}

// extractArgs 提取请求参数
func extractArgs(req interface{}) interface{} {
	if stringer, ok := req.(interface{ String() string }); ok {
		return stringer.String()
	}
	return req
}

// extractStack 提取错误堆栈
func extractStack(err error) interface{} {
	if err != nil {
		return err.Error()
	}
	return nil
}

// FromError 从错误中提取错误信息
func FromError(err error) (se *Error) {
	if err == nil {
		return nil
	}
	// 这里可以根据实际的错误类型进行转换
	return &Error{
		Code:   500,
		Reason: err.Error(),
	}
}

// Error 错误结构
type Error struct {
	Code   int32
	Reason string
}
