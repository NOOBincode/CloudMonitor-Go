package client

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/transport/http"
)

// HTTPClient HTTP客户端配置
type HTTPClient struct {
	client *http.Client
}

// NewHTTPClient 创建HTTP客户端
func NewHTTPClient(endpoint string, timeout time.Duration) (*HTTPClient, error) {
	client, err := http.NewClient(
		context.Background(),
		http.WithEndpoint(endpoint),
		http.WithTimeout(timeout),
		http.WithMiddleware(
			recovery.Recovery(),
		),
	)
	if err != nil {
		return nil, err
	}

	return &HTTPClient{client: client}, nil
}

// GetClient 获取HTTP客户端
func (c *HTTPClient) GetClient() *http.Client {
	return c.client
}
